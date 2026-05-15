from classes import Data, PulsePairResolution
import numpy as np # type: ignore

import warnings
#warnings.filterwarnings("error")
num_channels = 64

def find_binding_detected_events(left_most: int, right_most: int, true: int, detected):
    for i in range(1, len(detected)):
        right_most = i
        if detected[right_most] > true:
            left_most = right_most
            break
    return (left_most, right_most)

def add_to_true_by_detected(left_most, right_most, t_i, t, detected_times, true_by_detected):
    if abs(float(detected_times[left_most]) - t) < abs(float(detected_times[right_most]) - t):
        true_by_detected[left_most].append(t_i)
    else:
        true_by_detected[right_most].append(t_i)

def calculate_true_by_detected(detected_times, true_times) -> list[list[int]]:
    true_by_detected = [[] for _ in range(len(detected_times))]
    left_most, right_most = 0, 0
    for (t_i,t) in enumerate(true_times):
        if t_i == 0 and detected_times[left_most] > t:
            true_by_detected[left_most].append(t_i)
        elif t_i == len(true_times) - 1 and detected_times[-1] <= t:
            true_by_detected[right_most].append(t_i)
        else:
            (left_most, right_most) = find_binding_detected_events(left_most, right_most, t, detected_times)
            add_to_true_by_detected(left_most, right_most, t_i, float(t), detected_times, true_by_detected)
    return true_by_detected

def calculate_true_by_detected_metrics(detected_times, true_times, f):
    num_false_positives = len([x for x in f if len(x) == 0])
    num_false_negatives = sum(len(x) - 1 for x in f) + num_false_positives
    time_deviations = sum(sum(abs(float(true_times[t_i]) - float(d)) for t_i in f[i]) for (i,d) in enumerate(detected_times))
    #time_deviations = 0
    return (num_false_positives, num_false_negatives, time_deviations)

# Takes two data sets and returns a dict
def calculate_metrics(detected: Data, true: Data):
    num_false_positives, num_false_negatives, time_deviations = 0,0,0
    for i in range(len(detected.event_index) - 1):
        detected.set_event_range(i)
        true.set_event_range(i)
        for c in range(num_channels):
            detected_times = detected.get_frame_channel_times(c)
            true_times = true.get_frame_channel_times(c)
            f = calculate_true_by_detected(detected_times, true_times)
            (num_fp, num_fn, td) = calculate_true_by_detected_metrics(detected_times, true_times, f)
            num_false_positives += num_fp
            num_false_negatives +=num_fn
            time_deviations += td
    sz = num_channels*(len(detected.event_index) - 1)
    return num_false_positives/sz, num_false_negatives/sz, time_deviations/sz


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
