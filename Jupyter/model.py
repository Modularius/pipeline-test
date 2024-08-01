from typing import List
from my_trace import Span # type: ignore

import numpy as np

class Channel:
    def __init__(self, span : Span, template_span : Span):    # "find_channel_events in "trace-to-events"
        self.channel : int = span.get_int_tag('channel')
        self.start_time : int = span.start_time
        self.duration : int = span.duration

        self.num_pulses : int = span.get_int_tag('num_pulses')
        self.expected_pulses : int = template_span \
            .get_only_hero("New Trace", "simulator") \
            .get_only_hero("New Event List", "simulator") \
            .get_int_tag("num_pulses")

    def __str__(self):
        return f"      Pulses = {self.num_pulses}/{self.expected_pulses}, duration = {self.duration}"






class Digitiser:
    def __init__(self, span : Span):    # "process_kafka_message in "digitiser-aggregator"
        trace_to_events_span : Span = span.get_parent("process_digitiser_trace_message", "trace-to-events")
        simulator_span = trace_to_events_span \
            .get_parent("process_kafka_message", "trace-to-events") \
            .get_parent("Simulated Digitiser Trace","simulator") \
            .get_only_hero("send_digitiser_trace_message","simulator") \

        self.frame_number : int = simulator_span \
            .get_parent("run_digitiser","simulator") \
            .get_parent("run_frame","simulator") \
            .get_int_tag("frame_number")
        self.start_time : int = span.start_time
        self.duration : int = span.duration

        channels : List[Span] = trace_to_events_span \
            .get_only_child("process","trace-to-events") \
            .get_child_span_sublist("find_channel_events")
        channel_templates : List[Span] = simulator_span \
            .get_child_span_sublist("channel_trace")
        
        self.digitiser_id : int = simulator_span \
            .get_parent("run_digitiser","simulator") \
            .get_int_tag("digitiser_id")

        # Run through each "Digitiser Event List" of the frame, extracting the event formation span, and creating the Digitiser object
        self.channels : List[Channel] = [Channel(c, t) for c in channels for t in channel_templates if c.get_int_tag("channel") == t.get_int_tag("channel")]
        self.start_time : int = span.start_time
        self.duration : int = span.duration

        frame_complete = span.get_only_child("process_digitiser_event_list_message", "digitisier-aggregator").get_child_span_sublist("Frame Complete")
        if frame_complete:
            self.duration -= frame_complete[0].get_only_child("Message Producer", "digitisier-aggregator").duration
            

    def __str__(self):
        channels_str = "\n".join([str(c) for c in self.channels])
        return f"    Digitiser\n{channels_str}"
    
    def get_durations(self) -> List[int]:
        return [c.duration for c in self.channels]
    
    def mean_duration(self) -> float:
        return np.mean(self.get_durations())
    
    def max_duration(self) -> int:
        return np.max(self.get_durations())
    
    def sd_duration(self) -> float:
        return np.sd(self.get_durations()) # type: ignore





class Frame:
    def __init__(self, span : Span):    #   "Frame" in "digitiser-aggregator"
        # Run through each "Digitiser Event List" of the frame, extracting the event formation span, and creating the Digitiser object
        self.digitisers : List[Digitiser] = [
            Digitiser(s
                      .get_only_hero("process_digitiser_event_list_message", "digitiser-aggregator")
                      .get_parent("process_kafka_message", "digitiser-aggregator")
                      )
                    for s in span.get_child_span_sublist("Digitiser Event List")
        ]
        self.frame_number : int = self.digitisers[0].frame_number
        self.start_time : int = span.start_time
        self.duration = span.duration

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
                  .get_parent("Frame", "digitiser-aggregator")
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