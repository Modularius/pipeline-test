#nix-shell -p python312Packages.h5py -p python312Packages.scipy

import h5py
from scipy.optimize import curve_fit
from scipy.stats import binned_statistic
import numpy as np
import argparse

# Create parser with description
parser = argparse.ArgumentParser(description="Analyse Nexus File")

# Add positional arguments
parser.add_argument("file", type=str, help="File Path")

# Parse arguments
args = parser.parse_args()

f = h5py.File(args.file)
raw_data_1 = f["raw_data_1"]
detector_1_events = raw_data_1["detector_1_events"]
event_id = detector_1_events["event_id"]
event_index = detector_1_events["event_index"]
event_time_offset = detector_1_events["event_time_offset"]
pulse_height = detector_1_events["pulse_height"]

def summary(vals):
    print(len(vals), np.mean(vals), np.std(vals))

mu = 2.1969811
def exp_decay(x, ampl, mu):
    return ampl*np.exp(-x/mu)

mus = []
for i in range(len(event_index) - 1):
        event_range = range(event_index[i], event_index[i + 1])
    #for c in range(64):
        evt_id = event_id[event_range]
        offsets = event_time_offset[event_range]#[evt_id == c]
        results = binned_statistic(offsets, offsets, bins = 10, statistic = "count")
        x = (results.bin_edges[:-1] + results.bin_edges[1:])/2/1000
        y = results.statistic
        params = curve_fit(exp_decay, x, y, bounds = (0, [np.inf, np.inf]))
        mus.append(params[0][1])
        #print(f"a = {params[0][0]}, mu = {params[0][1]}")
print("Stats:")
print(np.mean(mus), np.std(mus))