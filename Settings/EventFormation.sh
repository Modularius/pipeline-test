set -a

#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
g_EF_INPUT_MODE="fixed-threshold-discriminator"
g_EF_FTD_THRESHOLD="2100"
g_EF_FTD_DURATION="1"
g_EF_FTD_COOLOFF="0"
g_EF_INPUT_COMMAND="fixed-threshold-discriminator --threshold ${g_EF_FTD_THRESHOLD} --duration ${g_EF_FTD_DURATION} --cool-off ${g_EF_FTD_COOLOFF}"