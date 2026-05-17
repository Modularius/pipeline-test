from scipy.optimize import curve_fit # type: ignore
from scipy.stats import binned_statistic # type: ignore
import numpy as np # type: ignore
import json

mu = 2.1969811
def exp_decay(x, ampl, mu):
    return ampl*np.exp(-x/mu)

def get_curve_lifetime(times):
    results = binned_statistic(times, times, bins = 10, statistic = "count")
    x = (results.bin_edges[:-1] + results.bin_edges[1:])/2/1000
    y = results.statistic
    params = curve_fit(exp_decay, x, y, bounds = (0, [np.inf, np.inf]))
    return params[0][1]

class Data:
    def __init__(self,f,indep: int):
        raw_data_1 = f["raw_data_1"]
        detector_1_events = raw_data_1["detector_1_events"]
        self.event_id = detector_1_events["event_id"]
        self.event_index = detector_1_events["event_index"]
        self.event_time_offset = detector_1_events["event_time_offset"]
        self.pulse_height = detector_1_events["pulse_height"]
        configuration = json.loads(raw_data_1["program_name"].attrs["configuration"].replace("'",'"'))
        self.detector = float(configuration["detector"][indep])

    def set_event_range(self, frame):
        #if frame + 1 == len(self.event_index):
        #else:
        #    event_range = range(self.event_index[frame + 1], len(self.event_id))
        event_range = range(self.event_index[frame], self.event_index[frame + 1])
        self.evt_id = self.event_id[event_range]
        self.evt_times = self.event_time_offset[event_range]
        self.evt_heights = self.pulse_height[event_range]
        
    def set_final_event_range(self):
        event_range = range(self.event_index[-1], len(self.event_id))
        self.evt_id = self.event_id[event_range]
        self.evt_times = self.event_time_offset[event_range]
        self.evt_heights = self.pulse_height[event_range]

    def get_frame_channel_times(self, channel):
        return self.evt_times[self.evt_id == channel]

    def get_frame_channel_data(self, channel):
        return self.evt_heights[self.evt_id == channel]
    
    def get_pulse_height_spectra(self, num_bins) -> list[int]:
       return binned_statistic(self.pulse_height, self.pulse_height, bins = num_bins, statistic = "count").statistic
    
    def get_log_time_spectra(self, num_bins) -> list[int]:
       return binned_statistic(self.event_time_offset, self.event_time_offset, bins = num_bins, statistic = "count").statistic

class SummaryStats:
    def __init__(self, values):
        self.count = len(values)
        if self.count > 0:
            self.mean = np.mean(values)
            self.min = np.min(values)
            self.max = np.max(values)
        else:
            self.mean = 0
            self.min = 0
            self.max = 0
        
        if self.count > 1:
            self.sd = np.std(values)
        else:
            self.sd = 0

class PulsePairResolution:
    def __init__(self):
        pass

    def extract(self, detector, true):
        diff_times_detector = detector[1:] - detector[:-1]
        diff_times_true = true[1:] - true[:-1]
        self.detector = np.min(diff_times_detector)
        self.true = np.min(diff_times_true)
