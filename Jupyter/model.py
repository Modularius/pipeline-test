from typing import List
from trace import Span # type: ignore

import numpy as np

class Channel:
    def __init__(self, span : Span, channel_template_span : Span):
        self.channel : int = span.get_int_tag('channel')
        self.start_time : int = span.start_time
        self.duration : int = span.duration

        self.num_pulses : int = span.get_int_tag('num_pulses')
        self.expected_pulses : int = channel_template_span.get_int_tag("num_pulses")

    def __str__(self):
        return f"      Pulses = {self.num_pulses}/{self.expected_pulses}, duration = {self.duration}"

class Digitiser:
    def __init__(self, span : Span):
        self.frame_number : int = span.get_parent("Trace").get_parent("Template").get_int_tag("frame_number")
        self.start_time : int = span.start_time
        self.duration : int = span.duration

        channels : List[Span] = span.get_only_child("process").get_child_span_sublist("find_channel_events")
        channel_templates : List[Span] = span.get_parent("Trace").get_only_child("send_trace_messages").get_child_span_sublist("Channel")
        
        self.channels : List[Channel] = [
            Channel(s,t) for s in channels for t in channel_templates if t.tags["channel"] == s.tags["channel"]
        ]
        self.start_time : int = span.start_time
        self.duration : int = span.duration

    def __str__(self):
        channels_str = "\n".join([str(c) for c in self.channels])
        return f"    Digitiser\n{channels_str}"
    
    def get_durations(self):
        return [c.duration for c in self.channels]
    
    def mean_duration(self):
        return np.mean(self.get_durations())
    
    def max_duration(self):
        return np.max(self.get_durations())
    
    def sd_duration(self):
        return np.sd(self.get_durations()) # type: ignore
    
class Frame:
    def __init__(self, span : Span):
        self.digitisers : List[Digitiser] = [
            Digitiser(s.get_only_hero("on_message").get_parent("Trace Source Message")) for s in span.get_child_span_sublist("Digitiser Event List")
        ]
        self.frame_number : int = self.digitisers[0].frame_number
        self.start_time : int = span.start_time
        self.duration = span.duration

    def __str__(self):
        digitiser_str = "\n".join([str(d) for d in self.digitisers])
        return f"  Frame\n{digitiser_str}"
    
    def get_durations(self):
        return [c.duration for d in self.digitisers for c in d.channel]
    
    def mean_duration(self):
        return np.mean(self.get_durations())
    
    def max_duration(self):
        return np.max(self.get_durations())
    
    def sd_duration(self):
        return np.sd(self.get_durations()) # type: ignore

class Run:
    def __init__(self, span : Span):
        self.frames : List[Frame] = [
            Frame(s.get_only_hero("process_kafka_message").get_parent("Frame")) for s in span.get_child_span_sublist("Frame Event List")
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