from typing import List, Tuple, Dict, Any
from model import Run
from benchmark import create_axes, plot_box_and_whisker
import run as rn

import numpy as np
import scipy as sp

import matplotlib.pyplot as plt

def get_digitisers_and_data_in_order(runs : List[Run], data : List[List[int]]) -> Tuple[List[int], List[List[int]]]:
    labels = [len(r.frames[0].digitisers) for r in runs]
    set_data = {labels[i]: data[i] for i in range(len(labels))}
    labels.sort()
    new_data = [set_data[l] for l in labels]
    return (labels,new_data)


def plot_channel_lifetimes_by_digitiser_count(runs : List[Run], figure, placement):
    channel_durations = [
        [c.duration_of_event_detection_for_for_channel
            for f in r.frames
            for d in f.digitisers
            for c in d.channels
            ]
        for r in runs
    ]
    (labels, channel_durations) = get_digitisers_and_data_in_order(runs, channel_durations)
    ax = create_axes('Event Formation Channel Times', "Num Digitisers", "Duration (us)", figure, placement, True)
    plot_box_and_whisker(ax, channel_durations, labels)
    







def plot_aggregator_frame_lifetimes(runs : List[Run], figure, placement):
    frame_digitisers_durations = [
        [f.frame_duration for f in r.frames ] for r in runs
    ]
    (labels, frame_digitisers_durations) = get_digitisers_and_data_in_order(runs, frame_digitisers_durations)

    ax = create_axes('Frame Assembler Frame Lifetimes', "Num Digitisers", "Duration (us)", figure, placement, True)
    plot_box_and_whisker(ax, frame_digitisers_durations, labels)

    means = [sp.stats.gmean(durs) for durs in frame_digitisers_durations]
    ax = create_axes('Frame Assembler Frame Lifetimes', "Num Digitisers", "Duration (us)", figure, placement, False)
    ax.scatter(labels,means)


def plot_aggregator_frame_digitiser_range(runs : List[Run], figure, placement):
    frame_digitisers_range = [
        [f.frame_digitiser_range for f in r.frames ] for r in runs
    ]
    (labels, frame_digitisers_range) = get_digitisers_and_data_in_order(runs, frame_digitisers_range)

    ax = create_axes('Frame Assembler Digitiser Range', "Num Digitisers", "Duration (us)", figure, placement, True)
    plot_box_and_whisker(ax, frame_digitisers_range, labels)

    means = [sp.stats.gmean(durs) for durs in frame_digitisers_range]
    ax = create_axes('Frame Assembler Digitiser Range', "Num Digitisers", "Duration (us)", figure, placement, False)
    ax.scatter(labels, means)

def plot_aggregator_producer_times(runs : List[Run], figure, placement):
    frame_prod_times = [
        [f.duration_frame_spent_producing_in_aggregator for f in r.frames ] for r in runs
    ]
    (labels, frame_prod_times) = get_digitisers_and_data_in_order(runs, frame_prod_times)

    ax = create_axes('Frame Assembler Digitiser Times', "Num Digitisers", "Duration (us)", figure, placement, True)
    plot_box_and_whisker(ax, frame_prod_times, labels)

    producer_times = [np.mean(durs) for durs in frame_prod_times]
    ax = create_axes('Frame Assembler Digitiser Times', "Num Digitisers", "Duration (us)", figure, placement, False)
    ax.scatter(labels, producer_times)

    
def plot_aggregator_frame_all_three(runs : List[Run], figure, placement):
    ax_f_lifetimes = create_axes('Frame Assembler Frame Lifetimes', "Num Digitisers", "Duration (us)", figure, placement, True)
    ax_f_range = create_axes('Frame Assembler Digitiser Range', "Num Digitisers", "Duration (us)", figure, placement, True)
    ax_f_producer = create_axes('Frame Assembler Producer Time', "Num Digitisers", "Duration (us)", figure, placement, True)
    ax = create_axes('Frame Assembler Times', "Num Digitisers", "Duration (us)", figure, placement, False)

    frame_digitisers_durations = [
        [f.frame_duration for f in r.frames ] for r in runs
    ]
    (labels, frame_digitisers_durations) = get_digitisers_and_data_in_order(runs, frame_digitisers_durations)

    frame_digitisers_range = [
        [f.frame_digitiser_range for f in r.frames ] for r in runs
    ]
    (labels, frame_digitisers_range) = get_digitisers_and_data_in_order(runs, frame_digitisers_range)

    frame_prod_times = [
        [f.duration_frame_spent_producing_in_aggregator for f in r.frames ] for r in runs
    ]
    (labels, frame_prod_times) = get_digitisers_and_data_in_order(runs, frame_prod_times)

    plot_box_and_whisker(ax_f_lifetimes, frame_digitisers_durations, labels)
    plot_box_and_whisker(ax_f_range, frame_digitisers_range, labels)
    plot_box_and_whisker(ax_f_producer, frame_prod_times, labels)

    duration_means = [sp.stats.gmean(durs) for durs in frame_digitisers_durations]
    ax.scatter(labels,duration_means)

    range_means = [sp.stats.gmean(durs) for durs in frame_digitisers_range]
    ax.scatter(labels, range_means)

    producer_times = [np.mean(durs) for durs in frame_prod_times]
    ax.scatter(labels, producer_times)


def plot_aggregator_frame_times_over_time(runs : List[Run]):
    figure = plt.figure(figsize = (10,4))
    width = 1/len(runs[0:8:1])
    for r, run in enumerate(runs[0:8:1]):
        placement = [r*width, 0, width, 1]
        rn.plot_aggregator_frame_lifetimes(run, 50//4, figure, placement)








def plot_nexus_writer_frame_time(runs : List[Run], figure, placement):
    frame_durations = [ [f.duration_frame_spent_in_writer for f in r.frames ] for r in runs ]
    (labels, frame_durations) = get_digitisers_and_data_in_order(runs, frame_durations)

    ax = create_axes('Nexus Writer Frame Lifetimes', "Num Digitisers", "Duration (us)", figure, placement, True)
    plot_box_and_whisker(ax, frame_durations, labels)









