from typing import Any, List, Dict
from Tree.scraper_interface import TraceScraperInterface
from TraceLib.span import Span

class Tree:
    def __init__(self, span: Span):
        self.span = span
        self.nodes: List[Tree] = []
    
    def get_children(self, scraper : TraceScraperInterface):
        self.nodes = [scraper.get_tree(r.trace_id, r.span_id) for r in self.span.refs]

    def get_all_children(self, scraper : TraceScraperInterface):
        self.get_children(scraper)
        for node in self.nodes:
            node.get_all_children(scraper)

    def get_earliest_start_time(self) -> int:
        if self.nodes is []:
            return self.span.start_time
        else:
            earliest_node_time = min(node.get_earliest_start_time() for node in self.nodes)
            return min(self.span.start_time, earliest_node_time)

    def get_causal_duration(self) -> int:
        return self.span.duration + (self.get_earliest_start_time() - self.span.start_time)
