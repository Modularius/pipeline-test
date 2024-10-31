import matplotlib.pyplot as plt
import pandas as pd

path = "../../Output/HiFi/"

frame = 0
channels = range(32,40)

# Modify these to zoom in
t0,t1 = 1000,6000

for channel in channels:
    df_raw = pd.read_csv(f"{path}output_f{frame}c{channel}_raw.csv", index_col = 0, header = None)
    df_pulse = pd.read_csv(f"{path}output_f{frame}c{channel}_pulses.csv", header = None)
    ax = df_raw.iloc[t0:t1].plot(figsize = (16,6))
    ax.axhline(y = 2200, color = "g", linewidth = 0.5, linestyle = "--")
    for _, pulse in df_pulse.iterrows():
        if pulse[0] in range(t0,t1):
            ax.axvline(x = pulse[0], color = "r", linewidth = 0.7)