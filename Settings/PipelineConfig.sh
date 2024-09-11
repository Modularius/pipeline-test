#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_POLARITY=positive
TTE_BASELINE=0
TTE_INPUT_MODE="fixed-threshold-discriminator --threshold=10 --duration=1 --cool-off=0"

DIGITIZERS="-d0 -d1 -d2 -d3 -d4 -d5 -d6 -d7"

NEXUS_OUTPUT_PATH="Output/Local"

OTEL_LEVEL="--otel-level=info"

OTEL_LEVEL_EVENT_FORMATION="--otel-level=off"
OTEL_LEVEL_AGGREGATOR="--otel-level=off"
OTEL_LEVEL_WRITER="--otel-level=off"
OTEL_LEVEL_SIM="--otel-level=off"

export RUST_LOG=info,digitiser_aggregator=off,nexus_writer=off,trace_to_events=off,$RUST_LOG_OFF
