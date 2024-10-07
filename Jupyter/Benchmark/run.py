from DataModel.model import Run
from benchmark import create_axes, plot_box_and_whisker

import numpy as np

import matplotlib.pyplot as plt

def plot_pulse_detections(run : Run, figure, placement):
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
    ax = create_axes('Number of Pulse Detections', "Frame", "Num Pulses", figure, placement, False)
    plot_box_and_whisker(ax, channel_num_pulses, labels)


def plot_pulse_correlations(run, figure, placement):
    expected_pulses, num_pulses = zip(*[
        (c.expected_pulses, c.num_pulses)
            for f in run.frames
            for d in f.digitisers
            for c in d.channels
    ])
    ax = figure.add_axes(placement)
    ax.set_xlabel('Expected Num Pulses')
    ax.set_ylabel('Actual Num Pulses Detected')
    ax.scatter(expected_pulses, num_pulses)


    

def plot_channel_lifetimes_by_frame(run : Run, figure, placement, frame_box_width : int = 10, ):
    frame_box_indices = range(len(run.frames)//frame_box_width)
    channel_durations = [
        [c.duration_of_event_detection_for_for_channel
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            for d in f.digitisers
            for c in d.channels
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    ax = create_axes('Channel Lifetimes', "Frame", "Duration (us)", True, figure, placement)
    plot_box_and_whisker(ax, channel_durations, labels)
    
def plot_digitiser_time_to_event_formation_by_frame(run : Run, figure, placement, frame_box_width : int = 10):
    frame_box_indices = range(len(run.frames)//frame_box_width)
    channel_durations = [
        [d.time_dat_message_arrived_in_event_formation - d.time_simulator_created_dat_message
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            for d in f.digitisers
        ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    ax = create_axes('Time Between Digitiser Simulation and Event Formation', "Frame", "Duration (us)", figure, placement, False)
    plot_box_and_whisker(ax, channel_durations, labels)
    
def plot_digitiser_time_to_aggregator_by_frame(run : Run, figure, placement, frame_box_width : int = 10):
    frame_box_indices = range(len(run.frames)//frame_box_width)
    channel_durations = [
        [d.time_dat_message_arrived_in_aggregator - d.time_dat_message_left_event_formation
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            for d in f.digitisers
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    ax = create_axes('Time Between Digitiser Event Formation and Aggregation', "Frame", "Duration (us)", figure, placement, True)
    plot_box_and_whisker(ax, channel_durations, labels)

def plot_frame_time_to_writer_by_frame(run : Run, figure, placement, frame_box_width : int = 10):
    frame_box_indices = range(len(run.frames)//frame_box_width)
    channel_durations = [
        [f.time_frame_arrived_in_writer - f.time_last_digitiser_arrived_in_aggregator
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    ax = create_axes('Time Between Final Digitiser in Aggregation and Frame in Writer', "Frame", "Duration (us)", figure, placement, True)
    plot_box_and_whisker(ax, channel_durations, labels)








def plot_digitiser_lifetimes(run : Run, figure, placement, frame_box_width : int = 10):
    frame_box_indices = range(len(run.frames)//frame_box_width)
    channel_durations = [
        [d.time_dat_message_arrived_in_aggregator
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            for d in f.digitisers
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    ax = create_axes('Digitiser Lifetimes', "Frame", "Duration (us)", True, figure, placement)
    plot_box_and_whisker(ax, channel_durations, labels)

    

def plot_aggregator_frame_lifetimes(run : Run, frame_box_width : int = 10, figure = plt.figure(figsize = (10,4)), placement = [0,0,1,1]):
    frame_box_indices = range(len(run.frames)//frame_box_width)
    digitiser_durations = [
        [f.duration_of_frame_in_aggregator
            for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]
            ]
        for f_i in frame_box_indices
        ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    ax = create_axes('Frame Assembler Digitiser Times', "Frame", "Duration (us)", True, figure, placement)
    plot_box_and_whisker(ax, digitiser_durations, labels)
        
def plot_nexus_writer_frame_time(run : Run, frame_box_width : int = 10, figure = plt.figure(figsize = (10,4))):
    frame_box_indices = range(len(run.frames)//frame_box_width)
    frame_durations = [
        [f.time_frame_arrived_in_writer for f in run.frames[f_i*frame_box_width:(f_i + 1)*frame_box_width]]
        for f_i in frame_box_indices
    ]
    labels = [f"{f_i*frame_box_width}-{(f_i + 1)*frame_box_width - 1}" for f_i in frame_box_indices]
    ax = create_axes('Nexus Writer Frame Times', "Frame", "Duration (us)", True, figure)
    plot_box_and_whisker(ax, frame_durations, labels)




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
