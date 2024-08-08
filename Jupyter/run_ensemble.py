from typing import List
from model import Run
from benchmark import plot_box_and_whisker, plot_scatter

import numpy as np
import scipy as sp

import matplotlib.pyplot as plt
    
    
def plot_event_formation(runs : List[Run]):
    run_box_width : int = 1
    run_box_indices = range(len(runs)//run_box_width)
    channel_durations = [
        [c.duration
            for r in runs[f_i*run_box_width:(f_i + 1)*run_box_width]
            for f in r.frames
            for d in f.digitisers
            for c in d.channels
            ]
        for f_i in run_box_indices
        ]
    labels = [len(r.frames[0].digitisers) for r in runs]
    duration_by_label = {labels[i]: channel_durations[i] for i in range(len(labels))}
    labels.sort()
    channel_durations = [duration_by_label[l] for l in labels]
    plot_box_and_whisker('Event Formation Channel Times', channel_durations, labels, "Num Digitisers", "Duration (us)", True)

def plot_aggregation(runs : List[Run]):
    frame_durations = [
        [f.duration for f in r.frames ] for r in runs
    ]
    frame_digitisers_durations = [
        [f.frame_duration for f in r.frames ] for r in runs
    ]
    frame_prod_times = [
        [f.producer_duration for f in r.frames ] for r in runs
    ]
    labels = [len(r.frames[0].digitisers) for r in runs]
    duration_by_label = {labels[i]: frame_durations[i] for i in range(len(labels))}
    digitiser_duration_by_label = {labels[i]: frame_digitisers_durations[i] for i in range(len(labels))}
    prod_time_by_label = {labels[i]: frame_prod_times[i] for i in range(len(labels))}
    labels.sort()
    digitiser_durations = [duration_by_label[l] for l in labels]
    frame_digitisers_durations = [digitiser_duration_by_label[l] for l in labels]
    digitiser_prod_times = [prod_time_by_label[l] for l in labels]

    plot_box_and_whisker('Frame Assembler Frame Times', digitiser_durations, labels, "Num Digitisers", "Duration (us)", True)

    plot_box_and_whisker('Frame Assembler Digitiser Times', frame_digitisers_durations, labels, "Num Digitisers", "Duration (us)", True)

    means = [sp.stats.gmean(durs) for durs in frame_digitisers_durations]
    plot_scatter('Frame Assembler Digitiser Times', means, labels, "Num Digitisers", "Duration (us)", False)
    
    producer_times = [np.mean(durs) for durs in digitiser_prod_times]
    plot_scatter('Frame Produce Times', producer_times, labels, "Num Digitisers", "Duration (us)", False)
        
def plot_writer(runs : List[Run]):
    run_box_width : int = 1
    run_box_indices = range(len(runs)//run_box_width)
    frame_durations = [
        [f.duration 
            for r in runs[f_i*run_box_width:(f_i + 1)*run_box_width]
            for f in r.frames
        ]
        for f_i in run_box_indices
    ]
    labels = [len(r.frames[0].digitisers) for r in runs]
    duration_by_label = {labels[i]: frame_durations[i] for i in range(len(labels))}
    labels.sort()
    frame_durations = [duration_by_label[l] for l in labels]
    plot_box_and_whisker('Nexus Writer Frame Times', frame_durations, labels, "Num Digitisers", "Duration (us)", True)


