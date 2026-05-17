#nix-shell -p python312Packages.h5py -p python312Packages.scipy -p python312Packages.matplotl
#python analysis/analysis.py -d Output/param_space/0/detector/completed/HighNoiseHighCount.nxs Output/param_space/1/detector/completed/HighNoiseHighCount.nxs Output/param_space/2/detector/completed/HighNoiseHighCount.nxs -t Output/param_space/0/true/completed/HighNoiseHighCount.nxs Output/param_space/1/detector/completed/HighNoiseHighCount.nxs Output/param_space/2/detector/completed/HighNoiseHighCount.nxs
#python analysis/analysis.py -d Output/param_space/0/detector/completed/NoNoiseHighCount.nxs Output/param_space/1/detector/completed/NoNoiseHighCount.nxs Output/param_space/2/detector/completed/NoNoiseHighCount.nxs -t Output/param_space/0/true/completed/NoNoiseHighCount.nxs Output/param_space/1/true/completed/NoNoiseHighCount.nxs Output/param_space/2/true/completed/NoNoiseHighCount.nxs
#python analysis/analysis.py -p Output/param_space -i /0 /1 /2 -d /detector -t /true -s /completed/NoNoiseHighCount.nxs

import h5py # type: ignore
import os
from classes import Data, PulsePairResolution
from tests import calculate_metrics, calculate_pulse_height_spectra_deviation, calculate_pulse_pair_resolutions, calculate_time_spectra_deviation
import numpy as np # type: ignore
import argparse
import matplotlib.pyplot as pl # type: ignore

# Create parser with description
parser = argparse.ArgumentParser(description="Analyse Nexus File")

# Add positional arguments
parser.add_argument("-p", "--prefix", type=str, help="Path of Event Formation Nexus File")
parser.add_argument("-s", "--suffix", type=str, help="Path of Event Formation Nexus File")
parser.add_argument("-f", "--filename", type=str, help="Nexus File Name (without extension)")
parser.add_argument("-i", "--iterate", nargs = "+", type=str, help="Path of Simulation Nexus File")
parser.add_argument("-d", "--detected", type=str, help="Path of Event Formation Nexus File")
parser.add_argument("-t", "--true", type=str, help="Path of Simulation Nexus File")
parser.add_argument("-g", "--images", type=str, help="Path of Simulation Nexus File")

# Parse arguments
args = parser.parse_args()


detected = [Data(h5py.File(f"{args.prefix}/{path}/{args.detected}/{args.suffix}/{args.filename}.nxs"), 2) for path in args.iterate]
true = [Data(h5py.File(f"{args.prefix}/{path}/{args.true}/{args.suffix}/{args.filename}.nxs"), 2) for path in args.iterate]

image_path = f"{args.images}/{args.filename}"
os.makedirs(image_path, exist_ok=True)

try:
    assert(len(detected) == len(true))
    for [det, tru] in zip(detected, true):
        assert(len(det.event_index) == len(tru.event_index))
except:
    print(len(detected), len(true))
    for [det, tru] in zip(detected, true):
        print(len(det.event_index), len(tru.event_index))
else:
    xdet = [d.detector for d in detected]
    xtru = [d.detector for d in detected]

    print("-- Metrics --")
    metrics = [calculate_metrics(det, tru) for [det, tru] in zip(detected, true)]
    false_pos = [x.num_false_positives for x in metrics]
    false_neg = [x.num_false_negatives for x in metrics]
    pl.figure()
    pl.title("False Counts")
    pl.xlabel("Threshold")
    pl.ylabel("Count")
    pl.plot(xdet, false_pos, label = "False Positives")
    pl.plot(xdet, false_neg, label = "False Negatives")
    pl.legend()
    pl.show()
    pl.savefig(f"{image_path}/False Events.png")
    
    time_dev = [x.time_deviations for x in metrics]
    pl.figure()
    pl.title("Average Time Deviation")
    pl.xlabel("Threshold")
    pl.ylabel("Time Deviation (ns)")
    pl.plot(xdet, time_dev)
    pl.show()
    pl.savefig(f"{image_path}/Time Deviation.png")
