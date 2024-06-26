BROKER="localhost:19092"
TRACE_TOPIC=Traces
DAT_EVENT_TOPIC=Events
FRAME_EVENT_TOPIC=FrameEvents
CONTROL_TOPIC=Controls
LOGS_TOPIC=Logs
SELOGS_TOPIC=SELogs
ALARMS_TOPIC=Alarms

INPUT=simulator
SIMULATOR_CONFIG_SOURCE="simulator_configs/data.json"
#SIMULATOR_CONFIG_SOURCE="simulator_configs/full_frame.json"
#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_POLARITY=positive
TTE_BASELINE=0
TTE_INPUT_MODE="fixed-threshold-discriminator --threshold=10 --duration=1 --cool-off=0"
DIGITIZERS="-d0 -d1 -d2 -d3 -d4 -d5 -d6 -d7"
#DIGITIZERS="-d0"
NEXUS_OUTPUT_PATH="Output/Local"

OTEL_LEVEL="--otel-level=info"
#OTEL_LEVEL=""

. ./libs/lib.sh
. ./tests/tests.sh

kill_persistant_components

export RUST_LOG=off,digitiser_aggregator=off,nexus_writer=off,trace_to_events=off,$RUST_LOG_OFF

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=broker up -d

run_persistant_components
run_timed_test

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-pipeline down
