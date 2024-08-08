from model import Run
from benchmark import plot_box_and_whisker

import numpy as np

import matplotlib.pyplot as plt

def plot_pulse_detections(run : Run):
    frame_box_width : int = 5
    frame_box_indices = range(len(run.frames)//frame_box_width)
    channel_num_pulses = [
        [c.num_pulses
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            for d in f.digitisers
            for c in d.channels
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    plot_box_and_whisker('Number of Pulse Detections', channel_num_pulses, labels, "Frame", "Num Pulses", False)


def plot_pulse_correlations(run):
    expected_pulses, num_pulses = zip(*[
        (c.expected_pulses, c.num_pulses)
            for f in run.frames
            for d in f.digitisers
            for c in d.channels
    ])
    figure = plt.figure(figsize = (10,4))
    ax = figure.add_axes([0,0,1,1])
    ax.set_xlabel('Expected Num Pulses')
    ax.set_ylabel('Actual Num Pulses Detected')
    ax.scatter(expected_pulses, num_pulses)


    
    
def plot_event_formation(run : Run):
    frame_box_width : int = 10
    frame_box_indices = range(len(run.frames)//frame_box_width)
    channel_durations = [
        [c.duration
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            for d in f.digitisers
            for c in d.channels
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    plot_box_and_whisker('Event Formation Channel Times', channel_durations, labels, "Frame", "Duration (us)", True)

def plot_aggregation(run : Run):
    frame_box_width : int = 10
    frame_box_indices = range(len(run.frames)//frame_box_width)
    digitiser_durations = [
        [d.duration
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            for d in f.digitisers
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    plot_box_and_whisker('Frame Assembler Digitiser Times', digitiser_durations, labels, "Frame", "Duration (us)", True)
        
def plot_writer(run : Run):
    frame_box_width : int = 10
    frame_box_indices = range(len(run.frames)//frame_box_width)
    frame_durations = [
        [f.duration for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]]
        for f_i in frame_box_indices
    ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    plot_box_and_whisker('Nexus Writer Frame Times', frame_durations, labels, "Frame", "Duration (us)", True)




def plot_timing_correlations(run, frame : int):
    figure = plt.figure(figsize = (10,4))
    channel_durations, ave_channel_durations = zip(*[
        (np.max(d.get_durations()), np.std(d.get_durations()))
            for f in run.frames
            for d in f.digitisers
            if f.frame_number == frame
        ]
    )
    ax = figure.add_axes([0.0,0,0.45,1])
    ax.set_xlabel('Channel Duration (us)')
    ax.set_ylabel('Standard Deviation of Digitiser Channel Duration (us)')
    ax.set_title("Correlation of channel durations to digitiser average channel duration")
    ax.scatter(channel_durations, ave_channel_durations, marker = ".") # type: ignore
    #return
    ave_channel_durations, digitiser_duration = zip(*[
        (np.mean(d.get_durations()), d.duration)
            for f in run.frames
            for d in f.digitisers
            if f.frame_number == frame
        ]
    )
    ax = figure.add_axes([0.55,0,0.45,1])
    ax.set_xlabel('Digitiser Duration (us)')
    ax.set_ylabel('Digitiser Mean Channel Duration (us)')
    ax.set_title("Correlation of digitiser average channel duration to digitiser duration")
    ax.scatter(ave_channel_durations, digitiser_duration, marker = ".") # type: ignore
