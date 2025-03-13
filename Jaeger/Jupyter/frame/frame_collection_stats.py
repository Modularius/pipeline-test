from typing import Optional, List, Tuple
from frame.frame import Aggragator_Frame
from frame.frame_stats import Stats, FrameStats
import math

class AggStats:
    def __init__(self, source : List[Stats]):
        assert(len(source) != 0)
        self.min = min([s.min for s in source])
        self.max = max([s.max for s in source])
        self.sum = sum([s.sum for s in source])
        self.len = sum([s.len for s in source])
        self.sum_of_squares = sum([s.sum_of_squares for s in source])
        self.mean = self.sum/self.len
        self.sd = self.std_dev()
    
    def std_dev(self):
        if self.len > 1:
            return math.sqrt((self.sum_of_squares - math.pow(self.sum,2)/self.len)/(self.len - 1))
        else:
            self.sd = 0

    def __str__(self):
        return f"{self.min} < {self.mean} (~{self.sd}) < {self.max}"

class FrameCollectionStats:
    def __init__(self, frames: List[Aggragator_Frame]):
        self.frames = frames
        stats = [FrameStats(frame) for frame in frames]

        child = [fs.child_digitiser_stats for fs in stats]
        child = [d for d in child if d is not None]

        self.child_trace_duration = AggStats([fs.trace_duration for fs in child])
        self.child_time_between = AggStats([fs.time_between for fs in child])
        self.child_eventlist_duration = AggStats([fs.eventlist_duration for fs in child])

        self.child_aggregator_to_writer_kafka_delta_ms = AggStats([fs.aggregator_to_writer_kafka_delta_ms for fs in child])
        self.child_event_formation_to_writer_kafka_delta_ms = AggStats([fs.event_formation_to_writer_kafka_delta_ms for fs in child])

        missing = [fs.missing_digitiser_stats for fs in stats]
        missing = [d for d in missing if d is not None]
        
        self.has_missing = missing != []
        if self.has_missing:
            self.missing_trace_duration = AggStats([fs.trace_duration for fs in missing])
            self.missing_time_between = AggStats([fs.time_between for fs in missing])
            self.missing_eventlist_duration = AggStats([fs.eventlist_duration for fs in missing])

            self.missing_event_formation_to_writer_kafka_delta_ms = AggStats([fs.aggregator_to_writer_kafka_delta_ms for fs in missing])
            self.missing_aggregator_to_writer_kafka_delta_ms = AggStats([fs.event_formation_to_writer_kafka_delta_ms for fs in missing])
        
    def print(self, prefix = ""):
        print(prefix, f"[Child Digitisers]")
        print(prefix, f"trace (us):               {self.child_trace_duration}")
        print(prefix, f"trace to eventlist (us):  {self.child_time_between}")
        print(prefix, f"eventlist (us):           {self.child_eventlist_duration}")
        print(prefix, f"trace to writer (ms):     {self.child_event_formation_to_writer_kafka_delta_ms}")
        print(prefix, f"eventlist to writer (ms): {self.child_aggregator_to_writer_kafka_delta_ms}")
        if self.has_missing:
            print(prefix, f"[Missing Digitisers]")
            print(prefix, f"trace (us):               {self.missing_trace_duration}")
            print(prefix, f"trace to eventlist (us):  {self.missing_time_between}")
            print(prefix, f"eventlist (us):           {self.missing_eventlist_duration}")
            print(prefix, f"trace to writer (ms):     {self.missing_event_formation_to_writer_kafka_delta_ms}")
            print(prefix, f"eventlist to writer (ms): {self.missing_aggregator_to_writer_kafka_delta_ms}")
