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
#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_POLARITY=positive
TTE_BASELINE=0
TTE_INPUT_MODE="constant-phase-discriminator --threshold=10 --duration=1 --cool-off=0"
DIGITIZERS="-d1 -d2 -d3 -d4 -d5 -d6 -d7 -d8"
NEXUS_OUTPUT_PATH="Output/Local"

. ./libs/lib.sh
. ./tests/tests.sh

docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=broker up -d
docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=pipeline up -d

run_full_test

sleep 1
#kill_persistant_components

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=broker down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=pipeline down
