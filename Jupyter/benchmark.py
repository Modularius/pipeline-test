from typing import List
from my_trace import TraceBank # type: ignore
from model import Run
import json
import requests
import time
import matplotlib.pyplot as plt

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
    #print("Event Formation Times")
    figure = plt.figure(0, figsize = (14,4))
    plot_event_formation(run, figure)

    figure = plt.figure(1, figsize = (14,4))
    #print("Digitiser Aggregation Times")
    plot_aggregation(run, figure)
    
def plot_event_formation(run : Run, figure):
    channel_frame_numbers = [f.frame_number + d.digitiser_id/32 for f in run.frames for d in f.digitisers for _ in d.channels]
    channel_durations = [c.duration for f in run.frames for d in f.digitisers for c in d.channels]
    
    frame_frame_numbers = [f.frame_number for f in run.frames]
    frame_frame_numbers.sort()
    frame_mean_durations = {f.frame_number: np.mean(f.get_channel_durations()) for f in run.frames}
    frame_max_durations = {f.frame_number: np.max(f.get_channel_durations()) for f in run.frames}

    figure.add_subplot(1,2,1)
    plt.scatter(channel_frame_numbers,channel_durations, marker = ".") # type: ignore
    plt.xlabel ('Frame Number')
    plt.ylabel ('Duration (us)')
    
    figure = plt.subplot(1,2,2)
    plt.plot(frame_frame_numbers,[frame_mean_durations[f] for f in frame_frame_numbers]) # type: ignore
    plt.plot(frame_frame_numbers,[frame_max_durations[f]  for f in frame_frame_numbers]) # type: ignore
    plt.xlabel ('Frame Number')
    plt.ylabel ('Duration (us)')
    
def plot_aggregation(run : Run, figure):
    digitiser_frame_numbers = [f.frame_number + d.digitiser_id/32 for f in run.frames for d in f.digitisers]
    digitiser_durations = [d.duration for f in run.frames for d in f.digitisers]
    
    frame_frame_numbers = [f.frame_number for f in run.frames]
    frame_frame_numbers.sort()
    frame_mean_durations = {f.frame_number: np.mean(f.get_digitiser_durations()) for f in run.frames}
    frame_max_durations = {f.frame_number: np.max(f.get_digitiser_durations()) for f in run.frames}

    figure.add_subplot(1,2,1)
    plt.scatter(digitiser_frame_numbers, digitiser_durations, marker = ".") # type: ignore
    plt.xlabel ('Frame Number')
    plt.ylabel ('Duration (us)')
    
    figure = plt.subplot(1,2,2)
    plt.plot(frame_frame_numbers,[frame_mean_durations[f] for f in frame_frame_numbers]) # type: ignore
    plt.plot(frame_frame_numbers,[frame_max_durations[f]  for f in frame_frame_numbers]) # type: ignore
    plt.xlabel ('Frame Number')
    plt.ylabel ('Duration (us)')
    
def plot_others(run : Run):
    channel_start_times = [c.start_time for f in run.frames for d in f.digitisers for c in d.channels]
    channel_frame_numbers = [f.frame_number for f in run.frames for d in f.digitisers for _ in d.channels]
    channel_durations = [c.duration for f in run.frames for d in f.digitisers for c in d.channels]
    
    digitiser_frame_numbers = [f.frame_number for f in run.frames for _ in f.digitisers]
    #digitiser_mean_durations = [d.max_duration() for f in run.frames for d in f.digitisers]

    frame_start_times = [f.start_time for f in run.frames]
    frame_frame_numbers = [f.frame_number for f in run.frames]
    #framer_mean_durations = [f.max_duration() for f in run.frames]

    plt.figure(0)
    plt.scatter(channel_start_times,channel_durations, marker = ".") # type: ignore
    plt.xlabel ('Start Time of Channel (ns from epoch)')
    plt.ylabel ('Duration (us)')

    plt.figure(1)
    plt.scatter(channel_frame_numbers,channel_durations, marker = ".") # type: ignore
    plt.xlabel ('Frame Number')
    plt.ylabel ('Duration (us)')
    
    plt.figure(2)
    plt.scatter(digitiser_frame_numbers,digitiser_mean_durations, marker = ".") # type: ignore
    plt.xlabel ('Frame Number')
    plt.ylabel ('Duration (us)')
    
    plt.figure(3)
    plt.scatter(frame_frame_numbers,framer_mean_durations, marker = ".") # type: ignore
    plt.xlabel ('Frame Number')
    plt.ylabel ('Duration (us)')
    
    plt.figure(4)
    plt.scatter(frame_start_times,framer_mean_durations, marker = ".") # type: ignore
    plt.xlabel ('Start Time of Frame (ns from epoch)')
    plt.ylabel ('Duration (us)')

#runs = get_last_n_runs(1)
#for run in runs:
#    plot(run)
