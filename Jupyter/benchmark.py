from typing import List
from trace import TraceBank # type: ignore
from model import Run
import json
import requests
import time
import matplotlib.pyplot as plt

def build_jaeger_traces_endpoint(service : str, operation : str) -> str:
    limit = 20000
    lookback_seconds = 60*60*2
    start_ms = int((time.time() - lookback_seconds)*1_000_000)
    end_ms = int(time.time()*1_000_000)
    return f"http://localhost:6686/api/traces?limit={limit}&lookback={lookback_seconds}s&service={service}&operation={operation}&start={start_ms}&end={end_ms}"

def get_traces(service : str, operation : str) -> TraceBank:
    """
    Returns list of all traces for a service
    """
    url = build_jaeger_traces_endpoint(service, operation)
    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.exceptions.HTTPError as err:
        raise err

    response = json.loads(response.text)
    traces = response["data"]
    return TraceBank(traces)

def get_last_n_runs(n : int) -> List[Run]:
    run_traces : TraceBank = get_traces("nexus-writer", "Run")
    frame_traces : TraceBank = get_traces("digitiser-aggregator", "Frame")
    event_formation_traces : TraceBank = get_traces("trace-to-events", "Trace Source Message")
    simulator_traces : TraceBank = get_traces("simulator", "Trace")
    
    simulator_traces.find_parents_from_traces(simulator_traces)
    event_formation_traces.find_parents_from_traces(event_formation_traces)
    event_formation_traces.find_parents_from_traces(simulator_traces)
    frame_traces.find_parents_from_traces(frame_traces)
    run_traces.find_parents_from_traces(run_traces)

    run_traces.find_heroes(frame_traces)
    frame_traces.find_heroes(event_formation_traces)
    
    return list(run_traces.get_span_subset("Run").values())[0:n]

def plot(run : Run):
    channel_start_times = [c.start_time for f in run.frames for d in f.digitisers for c in d.channels]
    channel_frame_numbers = [f.frame_number for f in run.frames for d in f.digitisers for _ in d.channels]
    channel_durations = [c.duration for f in run.frames for d in f.digitisers for c in d.channels]
    
    digitiser_frame_numbers = [f.frame_number for f in run.frames for _ in f.digitisers]
    digitiser_mean_durations = [d.max_duration() for f in run.frames for d in f.digitisers]

    frame_start_times = [f.start_time for f in run.frames]
    frame_frame_numbers = [f.frame_number for f in run.frames]
    framer_mean_durations = [f.max_duration() for f in run.frames]

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

runs = get_last_n_runs(6)
for run in runs:
    plot(run)
