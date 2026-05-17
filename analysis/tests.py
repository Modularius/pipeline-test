from classes import Data, PulsePairResolution
import numpy as np # type: ignore
from frame_channel import Channel

import warnings
#warnings.filterwarnings("error")
num_channels = 64

class Metrics:
    def __init__(self):
        self.num_false_positives = 0
        self.num_false_negatives = 0
        self.time_deviations = 0
    
    def normalise(self, num_frames: int, num_channels: int):
        sz = num_channels*num_frames
        self.num_false_positives /= sz
        self.num_false_negatives /= sz
        self.time_deviations /= sz


# Takes two data sets and returns a dict
def calculate_metrics(detected: Data, true: Data) -> Metrics:
    metrics = Metrics()
    for i in range(len(detected.event_index) - 1):
        detected.set_event_range(i)
        true.set_event_range(i)
        for c in range(num_channels):
            channel = Channel(c)
            channel.extract_metrics(detected, true)
            metrics.num_false_positives += channel.num_false_positives
            metrics.num_false_negatives +=channel.num_false_negatives
            metrics.time_deviations += channel.time_deviation

    
    detected.set_final_event_range()
    true.set_final_event_range()

    metrics.normalise(len(detected.event_index) - 1, num_channels)
    return metrics


# Takes two data sets and returns a dict
def calculate_pulse_pair_resolutions(detected: Data, true: Data):
    #pulse_pair_resolutions = []
    pulse_pair_resolutions_detector = 0
    pulse_pair_resolutions_true = 0
    for i in range(len(detected.event_index) - 1):
        detected.set_event_range(i)
        true.set_event_range(i)
        for c in range(num_channels):
            detected_times = detected.get_frame_channel_times(c)
            true_times = true.get_frame_channel_times(c)

            pulse_pair_resolutions_detector += min(detected_times[1:] - detected_times[:-1])
            pulse_pair_resolutions_true += min(true_times[1:] - true_times[:-1])
    det = float(pulse_pair_resolutions_detector/(num_channels*len(detected.event_index) - 1))
    tru = float(pulse_pair_resolutions_true/(num_channels*len(true.event_index) - 1))
    return (det, tru)

def calculate_time_spectra_deviation(detected: Data, true: Data, num_bins: int):
    detected_counts = detected.get_log_time_spectra(num_bins)
    true_counts = true.get_log_time_spectra(num_bins)
    return sum([float(t) - float(d) for (t,d) in zip(true_counts,detected_counts)])/len(detected_counts)

def calculate_pulse_height_spectra_deviation(detected: Data, true: Data, num_bins: int):
    detected_counts = detected.get_pulse_height_spectra(num_bins)
    true_counts = true.get_pulse_height_spectra(num_bins)
    return sum([float(t) - float(d) for (t,d) in zip(true_counts,detected_counts)])/len(detected_counts)
