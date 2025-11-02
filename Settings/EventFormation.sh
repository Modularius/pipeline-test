set -a

#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
#g_EF_INPUT_MODE="fixed-threshold-discriminator"
g_EF_INPUT_MODE="differential-threshold-discriminator"

g_EF_THRESHOLD="--threshold=20"
g_EF_DURATION="--duration=5"
g_EF_COOLOFF="--cool-off=10"

g_EF_CONSTANT_MULTIPLE="--constant-multiple=2"
#g_EF_CONSTANT_MULTIPLE=""

#g_EF_INPUT_COMMAND="fixed-threshold-discriminator --threshold ${g_EF_THRESHOLD} --duration ${g_EF_DURATION} --cool-off ${g_EF_COOLOFF}"
#g_EF_INPUT_COMMAND="${g_EF_INPUT_MODE} ${g_EF_THRESHOLD} ${g_EF_DURATION} ${g_EF_COOLOFF} ${g_EF_CONSTANT_MULTIPLE}"
#g_EF_INPUT_COMMAND="differential-threshold-discriminator --threshold ${g_EF_FTD_THRESHOLD} --duration ${g_EF_DURATION} --cool-off ${g_EF_COOLOFF} --constant-multiple 1.5 --central-fin-diff-radius 1"