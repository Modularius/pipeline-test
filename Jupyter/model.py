from typing import List
from my_trace import Span # type: ignore

import numpy as np

class Channel:
    def __init__(self, span : Span, template_span : Span):    # "find_channel_events in "trace-to-events"
        self.channel : int = span.get_int_tag('channel')
        self.time_event_detection_began_for_channel : int = span.start_time
        self.duration_of_event_detection_for_for_channel : int = span.duration

        self.num_pulses : int = span.get_int_tag('num_pulses')
        self.expected_pulses : int = template_span.get_int_tag('expected_pulses')

    def __str__(self):
        return f"      Pulses = {self.num_pulses}/{self.expected_pulses}, duration = {self.duration_of_event_detection_for_for_channel}"






class Digitiser:
    def __init__(self, span : Span):    # "process_digitiser_event_list_message in "digitiser-aggregator"
        trace_to_events_span : Span = span.get_parent("process_digitiser_trace_message", "trace-to-events")
        simulator_span : Span = trace_to_events_span.get_parent("Simulated Digitiser Trace","simulator")

        self.frame_number : int = simulator_span.get_int_tag("frame_number")
        self.digitiser_id : int = simulator_span.get_int_tag("digitiser_id")

        ### Simulator Times
        self.time_simulator_created_dat_message = simulator_span.start_time   # The time at which the simulator span was created

        ### Aggregator Times
        self.time_dat_message_arrived_in_aggregator : int = span.start_time
        self.duration_dat_message_spent_in_aggregator : int = span.duration
        self.duration_frame_event_list_spent_producing_in_aggregator : int = 0
        frame_complete = span.get_child_span_sublist("Frame Complete")
        if frame_complete:
            self.duration_frame_event_list_spent_producing_in_aggregator = frame_complete[0].get_only_child("Message Producer", "digitisier-aggregator").duration
            self.duration_dat_message_spent_in_aggregator -= self.duration_frame_event_list_spent_producing_in_aggregator
        self.time_dat_message_left_aggregator : int = span.start_time + span.duration

        ### Event Formation Times
        self.time_dat_message_arrived_in_event_formation = trace_to_events_span.start_time
        self.duration_dat_message_spent_in_event_formation = trace_to_events_span.duration
        self.time_dat_message_left_event_formation : int = trace_to_events_span.start_time + trace_to_events_span.duration

        channels : List[Span] = trace_to_events_span \
            .get_only_child("process","trace-to-events") \
            .get_child_span_sublist("find_channel_events")
        channel_templates : List[Span] = simulator_span \
            .get_only_hero("send_digitiser_trace_message","simulator") \
            .get_child_span_sublist("channel_trace")

        # Run through each "Digitiser Event List" of the frame, extracting the event formation span, and creating the Digitiser object
        self.channels : List[Channel] = [Channel(c, t) for c in channels for t in channel_templates if c.get_int_tag("channel") == t.get_int_tag("channel")]

            

    def __str__(self):
        channels_str = "\n".join([str(c) for c in self.channels])
        return f"    Digitiser\n{channels_str}"




class Frame:
    def __init__(self, span : Span):    #   "process_kafka_message" : "nexus-writer"
        digitiser_aggregator_span = span.get_parent("Frame", "digitiser-aggregator")
        # Run through each "Digitiser Event List" of the frame, extracting the event formation span, and creating the Digitiser object
        self.digitisers : List[Digitiser] = [
            Digitiser(s.get_only_hero("process_digitiser_event_list_message", "digitiser-aggregator"))
                for s in digitiser_aggregator_span.get_child_span_sublist("Digitiser Event List")
        ]
        self.frame_number : int = self.digitisers[0].frame_number

        self.time_frame_arrived_in_writer : int = span.start_time
        self.duration_frame_spent_in_writer : int = span.duration
        self.duration_frame_spent_producing_in_aggregator : int = np.sum([d.duration_frame_event_list_spent_producing_in_aggregator for d in self.digitisers])

        times_digitisers_arrive_in_aggregator = [s.start_time for s in digitiser_aggregator_span.get_child_span_sublist("Digitiser Event List")]
        self.time_first_digitiser_arrived_in_aggregator = np.min(times_digitisers_arrive_in_aggregator)
        self.time_last_digitiser_arrived_in_aggregator = np.max(times_digitisers_arrive_in_aggregator)
        self.range_of_times_digitisers_arrive_in_aggregator = self.time_last_digitiser_arrived_in_aggregator - self.time_first_digitiser_arrived_in_aggregator
        self.duration_of_frame_in_aggregator = digitiser_aggregator_span.duration

    def __str__(self):
        digitiser_str = "\n".join([str(d) for d in self.digitisers])
        return f"  Frame\n{digitiser_str}"




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