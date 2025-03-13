from frame.frame import Aggragator_Frame, Digitiser
from typing import List, Optional
import math

class Stats:
    def __init__(self, source : List[int]):
        assert(len(source) != 0)
        self.min = min(source)
        self.max = max(source)
        self.sum = sum(source)
        self.len = len(source)
        self.sum_of_squares = sum([x*x for x in source])
        self.mean = self.sum/self.len
        self.sd = self.std_dev()
    
    def std_dev(self):
        if self.len > 1:
            return math.sqrt((self.sum_of_squares - math.pow(self.sum,2)/self.len)/(self.len - 1))
        else:
            self.sd = 0


    def __str__(self):
        return f"{self.min} < {self.mean} (~{self.sd}) < {self.max}"

class DigitiserListStats:
    def __init__(self, digitisers: List[Digitiser], nexus_writer_kafka_timestamp_ms: int):
        durations = [d.get_span_durations() for d in digitisers if d is not None]
        durations = [d for d in durations if d is not None]

        self.trace_duration = Stats([d[0] for d in durations])
        self.time_between = Stats([d[1] for d in durations])
        self.eventlist_duration = Stats([d[2] for d in durations])

        kafka_timestamps = [d.get_kafka_timestamps() for d in digitisers if d is not None]
        kafka_timestamps = [d for d in kafka_timestamps if d is not None]
        self.aggregator_to_writer_kafka_delta_ms = Stats([nexus_writer_kafka_timestamp_ms - d[0] for d in kafka_timestamps])
        self.event_formation_to_writer_kafka_delta_ms = Stats([nexus_writer_kafka_timestamp_ms - d[1] for d in kafka_timestamps])
        
    def print(self, prefix = ""):
        print(prefix, f"trace (us):               {self.trace_duration}")
        print(prefix, f"trace to eventlist (us):  {self.time_between}")
        print(prefix, f"eventlist (us):           {self.eventlist_duration}")
        print(prefix, f"trace to writer (ms):     {self.event_formation_to_writer_kafka_delta_ms}")
        print(prefix, f"eventlist to writer (ms): {self.aggregator_to_writer_kafka_delta_ms}")

class FrameStats:
    def __init__(self, frame : Aggragator_Frame):
        self.child_digitiser_stats = None
        self.missing_digitiser_stats = None
        
        child_digitisers = [f.digitiser for f in frame.NexusWriter_DigitiserEventLists]
        if frame.NexusWriter_process_kafka_message.doc and child_digitisers != []:
            self.child_digitiser_stats = DigitiserListStats(child_digitisers, frame.kafka_timestamp_ms)
            if frame.missing_Aggregator_Digitisers:
                self.missing_digitiser_stats = DigitiserListStats(frame.missing_Aggregator_Digitisers, frame.kafka_timestamp_ms)
    
    def print(self):
        if self.child_digitiser_stats:
            print("Child Digitisers:")
            self.child_digitiser_stats.print("  ")

        if self.missing_digitiser_stats:
            print("Child Digitisers:")
            self.missing_digitiser_stats.print("  ")