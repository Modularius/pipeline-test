from typing import List
from my_trace import TraceBank # type: ignore
from model import Run
import json
import requests
import time
import matplotlib.pyplot as plt
import matplotlib.ticker

def build_jaeger_traces_endpoint(service : str, operation : str, lookback_minutes : int) -> str:
    limit = 500000
    lookback_seconds = 60*lookback_minutes
    start_ms = int((time.time() - lookback_seconds)*1_000_000)
    end_ms = int(time.time()*1_000_000)
    return f"http://localhost:6686/api/traces?limit={limit}&lookback={lookback_seconds}s&service={service}&operation={operation}&start={start_ms}&end={end_ms}"

def get_traces(service : str, operation : str, lookback_minutes : int) -> TraceBank:
    """
    Returns list of all traces for a service
    """
    print(f"Obtaining {operation} from {service}")
    url = build_jaeger_traces_endpoint(service, operation, lookback_minutes)
    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.exceptions.HTTPError as err:
        raise err

    print(f"  Response received. Processing json")
    response = json.loads(response.text)
    traces = response["data"]
    return traces

class TraceScrape:
    def __init__(self):
        pass
    
    def save(self):
        with open("run.json", 'x') as f:
            json.dump(self.run_json, f)
            f.close()
            
        with open("frame.json", 'x') as f:
            json.dump(self.frame_json, f)
            f.close()
            
        with open("nexus_writer.json", 'x') as f:
            json.dump(self.nexus_writer_json, f)
            f.close()
            
        with open("digitiser_aggregator.json", 'x') as f:
            json.dump(self.digitiser_aggregator_json, f)
            f.close()
            
        with open("event_formation.json", 'x') as f:
            json.dump(self.event_formation_json, f)
            f.close()
            
        with open("simulator.json", 'x') as f:
            json.dump(self.simulator_json, f)
            f.close()
    
    def load(self):
        with open("run.json", 'r') as f:
            self.run_json = json.load(f)
            f.close()
            
        with open("frame.json", 'r') as f:
            self.frame_json = json.load(f)
            f.close()
            
        with open("nexus_writer.json", 'r') as f:
            self.nexus_writer_json = json.load(f)
            f.close()
            
        with open("digitiser_aggregator.json", 'r') as f:
            self.digitiser_aggregator_json = json.load(f)
            f.close()
            
        with open("event_formation.json", 'r') as f:
            self.event_formation_json = json.load(f)
            f.close()
            
        with open("simulator.json", 'r') as f:
            self.simulator_json = json.load(f)
            f.close()

    def scrape(self, lookback_minutes : int):
        self.run_json : TraceBank = get_traces("nexus-writer", "Run", lookback_minutes)
        self.frame_json : TraceBank = get_traces("digitiser-aggregator", "Frame", lookback_minutes)
        self.nexus_writer_json : TraceBank = get_traces("nexus-writer", "process_kafka_message", lookback_minutes)
        self.digitiser_aggregator_json : TraceBank = get_traces("digitiser-aggregator", "process_digitiser_event_list_message", lookback_minutes)
        self.event_formation_json : TraceBank = get_traces("trace-to-events", "process_frame_assembled_event_list_message", lookback_minutes)
        self.simulator_json : TraceBank = get_traces("simulator", "run_configured_simulation", lookback_minutes)

    def make_trace_banks(self):
        self.run_traces : TraceBank = TraceBank(self.run_json)
        self.frame_traces : TraceBank = TraceBank(self.frame_json)
        self.nexus_writer_traces : TraceBank = TraceBank(self.nexus_writer_json)
        self.digitiser_aggregator_traces : TraceBank = TraceBank(self.digitiser_aggregator_json)
        self.event_formation_traces : TraceBank = TraceBank(self.event_formation_json)
        self.simulator_traces : TraceBank = TraceBank(self.simulator_json)

    def get_last_n_runs(self, n : int) -> List[Run]:
        collect = TraceBank({})
        collect.union(self.simulator_traces)
        collect.union(self.event_formation_traces)
        collect.union(self.digitiser_aggregator_traces)
        collect.union(self.nexus_writer_traces)
        collect.union(self.frame_traces)
        collect.union(self.run_traces)
        collect.extract_parents_from_traces(collect)
        collect.extract_heroes_from_traces(collect)
        
        runs = [list(trace.get_span_subset("Run").values())[0] for trace in self.run_traces.traces.values()]
        print(len(runs))
        
        return list(Run(run) for run in runs)[0:n]

def plot_box_and_whisker(title : str, durations, labels, xlabel : str, ylabel : str, is_ylog : bool = False):
    figure = plt.figure(figsize = (10,4))
    ax = figure.add_axes([0,0,1,1])
    ax.set_xlabel(xlabel)
    if is_ylog:
        ax.set_yscale('log')
        ax.set_yticks([2**e for e in range(20)])
        ax.get_yaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax.set_ylabel(ylabel)
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

def plot_scatter(title : str, durations, labels, xlabel : str, ylabel : str, is_ylog : bool = False):
    figure = plt.figure(figsize = (10,4))
    ax = figure.add_axes([0,0,1,1])
    ax.set_xlabel(xlabel)
    if is_ylog:
        ax.set_yscale('log')
        ax.set_yticks([2**e for e in range(20)])
        ax.get_yaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.scatter(labels, durations)
    
    return ax
