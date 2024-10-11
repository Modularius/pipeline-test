from typing import List, Dict
from Tree.scraper_interface import TraceScraperInterface
from TraceLib.span import Span
from Tree.my_tree import Tree
import json
import requests
import time

def build_jaeger_trace_endpoint(trace_id : str) -> str:
    return f"http://localhost:6686/api/traces/{trace_id}"

def build_jaeger_spans_endpoint(service : str, operation : str, lookback_minutes : int) -> str:
    limit = 500000
    lookback_seconds = 60*lookback_minutes
    start_ms = int((time.time() - lookback_seconds)*1_000_000)
    end_ms = int(time.time()*1_000_000)
    return f"http://localhost:6686/api/traces?limit={limit}&lookback={lookback_seconds}s&service={service}&operation={operation}&start={start_ms}&end={end_ms}"

class TraceScraper(TraceScraperInterface):
    def __init__(self):
        self.trace_id_log : List[str] = []
        self.spans : Dict[str,Tree] = dict()

    def scrape(self, url : str):
        print(f"   Scraping url {url}")
        try:
            response = requests.get(url)
            response.raise_for_status()
        except requests.exceptions.HTTPError as err:
            raise err

        print(f"   Response received. Processing json")
        return json.loads(response.text)

    def get_spans_init(self, service : str, operation : str, lookback_minutes : int):
        """
        Returns list of all traces for a service
        """
        print(f"Obtaining {operation} from {service}")
        url = build_jaeger_spans_endpoint(service, operation, lookback_minutes)
        traces = self.scrape(url)["data"]
        self.append_json_to_traces(traces)

    def append_json_to_traces(self, traces):
        self.trace_id_log.extend([t["traceID"] for t in traces])
        for trace in traces:
            for span in trace["spans"]:
                self.spans[span["spanID"]] = Tree(Span(span))
    
    def get_tree(self, trace_id: str, span_id: str) -> Tree:
        if trace_id not in self.trace_id_log:
            url = build_jaeger_trace_endpoint(trace_id)
            traces = self.scrape(url)["data"]
            self.append_json_to_traces(traces)
        
        tree =  self.spans[span_id]
        if tree is None:
            raise KeyError 
        else:
            return tree

    def init_spans(self):
        for tree in self.spans:
            self.spans[tree].get_all_children(self)