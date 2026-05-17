from scipy.optimize import curve_fit # type: ignore
from scipy.stats import binned_statistic # type: ignore
import numpy as np # type: ignore
import json
from classes import Data

num_channels = 64

def find_bounding_detected_events(left_most: int, right_most: int, true: int, detected):
    for i in range(1, len(detected)):
        right_most = i
        if detected[right_most] > true:
            left_most = right_most
            break
    return (left_most, right_most)

def add_to_true_events_by_nearest_detected_event(left_most, right_most, t_i, t, detected_times, true_by_detected):
    if abs(float(detected_times[left_most]) - t) < abs(float(detected_times[right_most]) - t):
        true_by_detected[left_most].append(t_i)
    else:
        true_by_detected[right_most].append(t_i)

class TrueEventRange:
    def __init__(self):
        self.left_most_index = 0
        self.right_most_index = 0

def calculate_true_events_by_nearest_detected_event(detected_times, true_times) -> list[list[int]]:
    true_by_detected = [[] for _ in range(len(detected_times))]
    left_most, right_most = 0, 0
    for (i,t) in enumerate(true_times):
        if i == 0 and detected_times[left_most] > t:
            true_by_detected[left_most].append(i)
        elif i == len(true_times) - 1 and detected_times[-1] <= t:
            true_by_detected[right_most].append(i)
        else:
            (left_most, right_most) = find_bounding_detected_events(left_most, right_most, t, detected_times)
            add_to_true_events_by_nearest_detected_event(left_most, right_most, i, float(t), detected_times, true_by_detected)
    return true_by_detected

class TrueEventsByNearestDetectedEvent:
    def __init__(self, detected_times, true_times):
        self.detected_times = detected_times
        self.true_times = true_times
        self.true_events_by_detected_events = [[] for _ in range(len(self.detected_times))]

    def get_nearest_detected_event_index(self, left_most_detected_index: int, time: int) -> int:
        left_bound_dist = abs(float(self.detected_times[left_most_detected_index]) - time)
        right_bound_dist = abs(float(self.detected_times[left_most_detected_index + 1]) - time)
        if left_bound_dist < right_bound_dist:
            return left_most_detected_index
        else:
            return left_most_detected_index + 1
    
    def build(self):
        left_bound_index = None
        for (i,t) in enumerate(self.true_times):
            if left_bound_index is None:
                index = 0
                
                if self.detected_times[0] < t:
                    left_bound_index = 0

            elif left_bound_index + 2 < len(self.detected_times):
                index = self.get_nearest_detected_event_index(left_bound_index, t)
                
                if self.detected_times[left_bound_index + 1] < t:
                    left_bound_index += 1
            else:
                index = -1
                    
            self.true_events_by_detected_events[index].append(i)
        
    def assert_built(self):
        image_union = [t for true_events in self.true_events_by_detected_events for t in true_events]
        image_union.sort()
        assert(image_union == list(range(len(self.true_times))))

    def get_false_positives(self):
        return len( [true_events
                for true_events in self.true_events_by_detected_events
                    if len(true_events) == 0
                ])

    def get_false_negatives_positives_diff(self):
        return sum(len(true_events) - 1
                    for true_events in self.true_events_by_detected_events
                )
    
    def get_nontrivial_detected_times_and_associated_true_times(self):
        return [
                ( float(d),
                    [ float(self.true_times[i])
                        for i in self.true_events_by_detected_events[i]
                    ]
                ) for (i,d) in enumerate(self.detected_times)
                    if len(self.true_events_by_detected_events[i]) != 0
            ]

class Channel:
    def __init__(self,channel: int):
        self.channel = channel

    def extract_metrics(self, detected: Data, true: Data):
        detected_times = detected.get_frame_channel_times(self.channel)
        true_times = true.get_frame_channel_times(self.channel)
        
        # true_events_by_nearest_detected_event : DetectedEvents -> Pow(TrueEvents)
        # this function partitions TrueEvents, that is the union of the image equals TrueEvents,
        # and the intersection of the image is empty.
        true_events_by_nearest_detected_event = TrueEventsByNearestDetectedEvent(detected_times, true_times)
        true_events_by_nearest_detected_event.build()
        #true_events_by_nearest_detected_event.assert_built()
        self.num_false_positives = true_events_by_nearest_detected_event.get_false_positives()
        self.num_false_negatives = true_events_by_nearest_detected_event.get_false_negatives_positives_diff() + self.num_false_positives
        
        num_nontrivial_detected = len(true_events_by_nearest_detected_event.detected_times) - true_events_by_nearest_detected_event.get_false_positives()
        self.time_deviation = sum(
            sum(abs(t - d) for t in true_times)/len(true_times)
                for (d,true_times) in true_events_by_nearest_detected_event.get_nontrivial_detected_times_and_associated_true_times()
        )/num_nontrivial_detected
