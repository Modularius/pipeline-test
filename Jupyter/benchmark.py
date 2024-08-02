from typing import List
from my_trace import TraceBank # type: ignore
from model import Run
import json
import requests
import time
import matplotlib.pyplot as plt
import matplotlib.ticker

import numpy as np

def build_jaeger_traces_endpoint(service : str, operation : str) -> str:
    limit = 200000
    lookback_seconds = 60*2
    start_ms = int((time.time() - lookback_seconds)*1_000_000)
    end_ms = int(time.time()*1_000_000)
    return f"http://localhost:6686/api/traces?limit={limit}&lookback={lookback_seconds}s&service={service}&operation={operation}&start={start_ms}&end={end_ms}"

def get_traces(service : str, operation : str) -> TraceBank:
    """
    Returns list of all traces for a service
    """
    print(f"Obtaining {operation} from {service}")
    url = build_jaeger_traces_endpoint(service, operation)
    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.exceptions.HTTPError as err:
        raise err

    response = json.loads(response.text)
    traces = response["data"]
    return TraceBank(traces)

class TraceScrape:
    def __init__(self):
        self.run_traces : TraceBank = get_traces("nexus-writer", "Run")
        self.frame_traces : TraceBank = get_traces("digitiser-aggregator", "Frame")
        self.event_formation_traces : TraceBank = get_traces("trace-to-events", "process_kafka_message")
        self.simulator_traces : TraceBank = get_traces("simulator", "run_schedule")


    def get_last_n_runs(self, n : int) -> List[Run]:
        #simulator_traces.extract_parents_from_traces(simulator_traces)
        #event_formation_traces.extract_parents_from_traces(event_formation_traces)
        #event_formation_traces.extract_parents_from_traces(simulator_traces)
        #frame_traces.extract_parents_from_traces(frame_traces)
        #run_traces.extract_parents_from_traces(run_traces)

        collect = TraceBank({})
        collect.union(self.simulator_traces)
        collect.union(self.event_formation_traces)
        collect.union(self.frame_traces)
        collect.union(self.run_traces)
        collect.extract_parents_from_traces(collect)
        collect.extract_heroes_from_traces(collect)
        
        #run_traces
        #frame_traces.extract_heroes_from_traces(collect)
        #simulator_traces.extract_heroes_from_traces(collect)
        #frame_traces.extract_heroes_from_traces(simulator_traces)
        
        return list(Run(list(trace.get_span_subset("Run").values())[0]) for trace in self.run_traces.traces.values())[0:n]

def plot(run : Run):
    plot_event_formation(run)
    plot_aggregation(run)
    plot_writer(run)

def plot_box_and_whisker(title, durations, labels):
    figure = plt.figure(figsize = (10,4))
    ax = figure.add_axes([0,0,1,1])
    ax.set_xlabel('Frame')
    ax.set_yscale('log')
    ax.set_ylabel('Duration (us)')
    ax.set_yticks([2**e for e in range(16)])
    ax.get_yaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax.set_title(title)
    bp = ax.boxplot(durations, meanline = True, labels = labels)
    
    for whisker in bp['whiskers']:
        whisker.set(color ='#8B008B',
                    linewidth = 1.5,
                    linestyle =":")
    
    for cap in bp['caps']:
        cap.set(color ='#8B008B',
                linewidth = 2)
        
    for flier in bp['fliers']:
        flier.set(marker ='.',
                color ='#FF0000',
                alpha = 0.25)

    return ax
    
def plot_event_formation(run : Run):
    frame_box_width : int = 10
    frame_box_indices = range(len(run.frames)//frame_box_width)
    channel_durations = [
        [c.duration
            for f in run.frames[f_i*10:(f_i + 1)*frame_box_width]
            for d in f.digitisers
            for c in d.channels
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    plot_box_and_whisker('Event Formation Channel Times', channel_durations, labels)

def plot_aggregation(run : Run):
    frame_box_width : int = 10
    frame_box_indices = range(len(run.frames)//frame_box_width)
    digitiser_durations = [
        [d.duration
            for f in run.frames[f_i*10:(f_i + 1)*frame_box_width]
            for d in f.digitisers
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    plot_box_and_whisker('Frame Assembler Digitiser Times', digitiser_durations, labels)
        
def plot_writer(run : Run):
    frame_box_width : int = 10
    frame_box_indices = range(len(run.frames)//frame_box_width)
    frame_durations = [
        [f.duration for f in run.frames[f_i*10:(f_i + 1)*frame_box_width]]
        for f_i in frame_box_indices
    ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    ax = plot_box_and_whisker('Nexus Writer Frame Times', frame_durations, labels)




def plot_correlations(run):
    figure = plt.figure(figsize = (10,4))
    channel_durations, ave_channel_durations = zip(*[
        (c.duration, np.std(d.get_durations()))
            for f in run.frames
            for d in f.digitisers
            for c in d.channels
        ]
    )
    ax = figure.add_axes([0.0,0,0.45,1])
    ax.set_xlabel('Channel Duration (us)')
    ax.set_ylabel('Standard Deviation of Digitiser Channel Duration (us)')
    ax.set_title("Correlation of channel durations to digitiser average channel duration")
    ax.scatter(channel_durations, ave_channel_durations, marker = ".") # type: ignore
    return
    ave_channel_durations, digitiser_duration = zip(*[
        (np.mean(d.get_durations()), d.duration)
            for f in run.frames
            for d in f.digitisers
        ]
    )
    ax = figure.add_axes([0.55,0,0.45,1])
    ax.set_xlabel('Digitiser Duration (us)')
    ax.set_ylabel('Digitiser Mean Channel Duration (us)')
    ax.set_title("Correlation of digitiser average channel duration to digitiser duration")
    ax.scatter(ave_channel_durations, digitiser_duration, marker = ".") # type: ignore
