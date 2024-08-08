from typing import List
from my_trace import Span # type: ignore

import numpy as np

class Channel:
    def __init__(self, span : Span, template_span : Span):    # "find_channel_events in "trace-to-events"
        self.channel : int = span.get_int_tag('channel')
        self.start_time : int = span.start_time
        self.duration : int = span.duration

        self.num_pulses : int = span.get_int_tag('num_pulses')
        self.expected_pulses : int = template_span.get_int_tag('expected_pulses')

    def __str__(self):
        return f"      Pulses = {self.num_pulses}/{self.expected_pulses}, duration = {self.duration}"






class Digitiser:
    def __init__(self, span : Span):    # "process_kafka_message in "digitiser-aggregator"
        trace_to_events_span : Span = span.get_parent("process_digitiser_trace_message", "trace-to-events")
        simulator_span : Span = trace_to_events_span.get_parent("Simulated Digitiser Trace","simulator")

        self.frame_number : int = simulator_span.get_int_tag("frame_number")
        self.start_time : int = span.start_time
        self.duration : int = span.duration

        channels : List[Span] = trace_to_events_span \
            .get_only_child("process","trace-to-events") \
            .get_child_span_sublist("find_channel_events")
        channel_templates : List[Span] = simulator_span \
            .get_only_hero("send_digitiser_trace_message","simulator") \
            .get_child_span_sublist("channel_trace")
        
        self.digitiser_id : int = simulator_span.get_int_tag("digitiser_id")

        # Run through each "Digitiser Event List" of the frame, extracting the event formation span, and creating the Digitiser object
        self.channels : List[Channel] = [Channel(c, t) for c in channels for t in channel_templates if c.get_int_tag("channel") == t.get_int_tag("channel")]
        self.start_time : int = span.start_time
        self.duration : int = span.duration

        '''
            If there is a Frame Complete child span, then it's Message Producer child
            span may persist longer than the time we wish to measure, so we subtract
            its duration from this one.
        '''
        frame_complete = span.get_child_span_sublist("Frame Complete")
        self.producer_time = 0
        if frame_complete:
            self.producer_time = frame_complete[0].get_only_child("Message Producer", "digitisier-aggregator").duration
            self.duration -= self.producer_time
            

    def __str__(self):
        channels_str = "\n".join([str(c) for c in self.channels])
        return f"    Digitiser\n{channels_str}"
    
    def get_durations(self) -> List[int]:
        return [c.duration for c in self.channels]
    
    def mean_duration(self) -> float:
        return np.mean(self.get_durations()) # type: ignore
    
    def max_duration(self) -> int:
        return np.max(self.get_durations())
    
    def sd_duration(self) -> float:
        return np.sd(self.get_durations()) # type: ignore





class Frame:
    def __init__(self, span : Span):    #   "process_kafka_message" : "nexus-writer"
        digitiser_aggregator_span = span.get_parent("Frame", "digitiser-aggregator")
        # Run through each "Digitiser Event List" of the frame, extracting the event formation span, and creating the Digitiser object
        self.digitisers : List[Digitiser] = [
            Digitiser(s.get_only_hero("process_digitiser_event_list_message", "digitiser-aggregator"))
                for s in digitiser_aggregator_span.get_child_span_sublist("Digitiser Event List")
        ]
        self.frame_number : int = self.digitisers[0].frame_number
        self.start_time : int = span.start_time
        self.duration = span.duration
        self.producer_duration = np.sum([d.producer_time for d in self.digitisers])
        
        frame_complete = span.get_only_child("process_frame_assembled_event_list_message", "digitisier-aggregator").get_child_span_sublist("Frame Complete")
        if frame_complete:
            self.duration -= frame_complete[0].get_only_child("Message Producer", "digitisier-aggregator").duration

        start_times = [s.start_time for s in digitiser_aggregator_span.get_child_span_sublist("Digitiser Event List")]
        self.frame_duration = np.max(start_times) - np.min(start_times)

    def __str__(self):
        digitiser_str = "\n".join([str(d) for d in self.digitisers])
        return f"  Frame\n{digitiser_str}"
    
    def get_channel_durations(self):
        return [c.duration for d in self.digitisers for c in d.channels]
    
    def get_digitiser_durations(self):
        return [d.duration for d in self.digitisers]

    def sd_duration(self):
        return np.sd(self.get_durations()) # type: ignore





class Run:
    def __init__(self, span : Span):    # "Run" in "nexus-writer"
        # Run through each "Frame Event List" of the run, extracting the aggregator span, and creating the Frame object
        self.frames : List[Frame] = [
            Frame(s
                  .get_only_hero("process_frame_assembled_event_list_message", "nexus-writer")
                  .get_parent("process_kafka_message", "nexus-writer")
                  )
                for s in span.get_child_span_sublist("Frame Event List")
        ]
        self.start_time = span.start_time
        self.duration = span.duration

    def __str__(self):
        frame_str = "\n".join([str(f) for f in self.frames])
        return f"Run\n{frame_str}"
    
    def validate(self, num_digitisers : int, num_channels_per_digitiser : int) -> bool:
        for f in self.frames:
            if len(f.digitisers) != num_digitisers:
                return False
            for d in f.digitisers:
                if len(d.channels) != num_channels_per_digitiser:
                    return False
        return True