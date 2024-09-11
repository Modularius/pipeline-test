#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_POLARITY=positive
TTE_BASELINE=0
TTE_INPUT_MODE="fixed-threshold-discriminator --threshold=10 --duration=1 --cool-off=0"

DIGITIZERS="-d0 -d1 -d2 -d3 -d4 -d5 -d6 -d7"

NEXUS_OUTPUT_PATH="Output/Local"

OTEL_ENDPOINT="http://localhost:4317/v1/traces"
#OTEL_ENDPOINT="http://146.199.207.182:4317/v1/traces"
OTEL_LEVEL="--otel-level=info"