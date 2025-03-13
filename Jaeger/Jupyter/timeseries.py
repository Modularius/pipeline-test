from typing import List, Dict, Optional, Any
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
import numpy as np
from lib import filter_bool_must_terms, filter_term_op_name, convert_es_to_python_dateformat, ESQuery

### These functions count the number of different types of documents
### and bins them by time.

### Data Gathering
def do_counting(client, index: str, es_query: ESQuery, hist_freq: str, format: str) -> Dict[str,Any]:
    query = { "bool" : { "filter": es_query.get_queries() } }
    
    histogram = { "hist": {    
        "date_histogram": {
            "field": "startTimeMillis", "fixed_interval": hist_freq, "format": format
        }
    } }
    
    filters = {
        "count_traces": filter_term_op_name("process_digitiser_trace_message"),
        "count_digitiser_eventlists": filter_term_op_name("process_digitiser_event_list_message"),
        "count_frame_eventlists": filter_term_op_name("process_frame_assembled_event_list_message"),
        "count_Frames": filter_term_op_name("Frame"),
        "count_incomplete_Frames": filter_bool_must_terms([
            { "operationName": "Frame" }, { "tag.frame_is_expired": "true" }
        ]),
        "count_discarded_digitiser_eventlists": filter_bool_must_terms([
            { "operationName": "process_digitiser_event_list_message" }, { "tag.is_discarded": "true" }
        ]),
    }
    
    aggregations = histogram
    aggregations["hist"]["aggregations"] = filters

    body = {
        "query": query,
        "aggregations": aggregations,
        "_source": False,
        "size": 0
    }
    result = client.search(index=index, body=body)
    return result.raw["aggregations"]



def get_frame_children_by_run(client, index: str, es_query: ESQuery) -> Dict[str,int]:
    es_query.add_service_and_op_name("nexus-writer", "Frame Event List")
    query = { "bool" : { "filter": es_query.get_queries() } }
    
    by_run = { "by_run": { "terms": {
        "field": "parentSpanID",
        "size": 10000,
    } } }
    body = {
        "query": query,
        "aggregations": by_run,
        "_source": False,
        "size": 0
    }
    result = client.search(index=index, body=body)
    buckets = result.raw["aggregations"]["by_run"]["buckets"]
    num_by_run = dict()
    for bucket in buckets:
        num_by_run[bucket["key"]] = bucket["doc_count"]
    return num_by_run

def get_runs(client, index: str, es_query: ESQuery):
    op_name_query = { "term": { "operationName": "Run" } }
    musts = es_query.get_queries_with([ op_name_query])
    query = { "bool" : { "must": musts } }

    fields = ["startTime", "duration", "spanID", "tag.run_name", "tag.instrument_name", "tag.run_has_run_stop"]
    body = {
        "query": query,
        "fields": fields,
        "_source": False,
        "size": 10000
    }
    result = client.search(index=index, body=body)
    return [hit["fields"] for hit in result.raw["hits"]["hits"]]




### Data Processing

def process_counts(result):
    data = []
    for bucket in result["hist"]["buckets"]:
        trace = bucket["count_traces"]["doc_count"]
        evtlist = bucket["count_digitiser_eventlists"]["doc_count"]
        if trace != evtlist:
            time = bucket["key_as_string"]
            #print(f"Trace/Event List mismatch at {time}: {trace}/{evtlist}")
        frame_evtlist = bucket["count_frame_eventlists"]["doc_count"]
        frames = bucket["count_Frames"]["doc_count"]
        if frame_evtlist != frames:
            time = bucket["key_as_string"]
            #print(f"Frame Event List/Frame mismatch at {time}: {frame_evtlist}/{frames}")
        data.append({
            "digitiser_eventlists": bucket["count_digitiser_eventlists"]["doc_count"],
            "Frames": bucket["count_Frames"]["doc_count"],
            "incomplete_Frames": bucket["count_incomplete_Frames"]["doc_count"],
            "discarded_digitiser_eventlists": bucket["count_discarded_digitiser_eventlists"]["doc_count"],
            "times": datetime.fromtimestamp(bucket["key"]/1_000)
        })
    return data

def process_runs(frames: Dict[str,int], runs: List[Dict[str,Any]]) -> List[Dict[str,int]]:
    for run in runs:
        num_frames = frames.get(run["spanID"][0])
        run["num_frames"] = 0
        if num_frames:
            run["num_frames"] = num_frames
        run["startTime"] = datetime.fromtimestamp(run["startTime"][0]/1_000_000)
        run["duration"] =  timedelta(microseconds=run["duration"][0])
    return runs
    


### Data Display

def hist_count_results(buckets, runs, date_format: str, bin_width: str, height: int = 4):
    expected_num_digitisers = 8
    datetimes = [bucket["times"] for bucket in buckets]

    plt.rcParams["figure.figsize"] = (14,height)
    if runs:
        _, ax = plt.subplots(3,1, layout='constrained')
    else:
        _, ax = plt.subplots(2,1, layout='constrained')

    digitiser_eventlists = [bucket["digitiser_eventlists"] for bucket in buckets]
    Frames = [bucket["Frames"]*expected_num_digitisers for bucket in buckets]
    plt.xticks(rotation=90)
    if runs:
        my_axis = ax[0]
        my_axis.set_ylabel(f"Digitiser Event Lists (Linear) / Run")
        start, width, num_frames = [run["startTime"] for run in runs], [run["duration"] for run in runs], [run["num_frames"] for run in runs]
        colour = ["b" for _ in runs]
        my_axis.set_title('Runs')
        my_axis.bar(start, num_frames, width, edgecolor = "black", color=colour, alpha=0.1)

    datetimes = [dt.strftime(convert_es_to_python_dateformat(date_format)) for dt in datetimes]
    x = np.arange(len(datetimes))
    my_axis = ax[1] if runs else ax[0]
    show_paired_bars(my_axis, "Digitiser and Frame Event Lists", f"Message Count (Linear) / {bin_width}", False, x, digitiser_eventlists, "Digitiser Event Lists", Frames, f"Frames (scaled by {expected_num_digitisers})")
    my_axis.set_xticks([])
    my_axis.set_xlabel("")

    discarded_digitiser_eventlists = [bucket["discarded_digitiser_eventlists"] for bucket in buckets]
    incomplete_Frames = [bucket["incomplete_Frames"]*expected_num_digitisers for bucket in buckets]
    my_axis = ax[2] if runs else ax[1]
    show_paired_bars(my_axis, None, f"Message Count (Log) / {bin_width}", True, x, discarded_digitiser_eventlists, "Discarded Digitiser Event Lists", incomplete_Frames, f"Incomplete Frames (scaled by {expected_num_digitisers})")
    if runs:
        #my_axis.set_xticks(ax[0].get_xticks(), ax[0].get_xticklabels())
        my_axis.set_xticks(x[::2], datetimes[::2])
    else:
        my_axis.set_xticks(x[::2], datetimes[::2])
    my_axis.set_xlabel(f"Date/Time ({date_format})")

    plt.show()

def show_paired_bars(my_axis, title: Optional[str], ylabel: str, log: bool, start, left_data, left_label, right_data, right_label):
    if title:
        my_axis.set_title(title)
    if log:
        my_axis.set_yscale("log")
    my_axis.set_ylabel(ylabel)
    my_axis.bar(start + 0.1, height = left_data, width=0.4, color=(1,0,0), label=left_label)
    my_axis.bar(start + 0.5, height = right_data, width=0.4, color=(0.4,0,0), label=right_label)
    my_axis.legend(loc='upper left', ncols=2)