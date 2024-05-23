BROKER="130.246.55.29:9092"
TRACE_TOPIC=daq-traces-in
DAT_EVENT_TOPIC=daq-events-in
FRAME_EVENT_TOPIC=ics-_events
CONTROL_TOPIC=ics-control-change
LOGS_TOPIC=ics-metadata
SELOGS_TOPIC=ics-metadata
ALARMS_TOPIC=ics-alarms

#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_POLARITY=positive
TTE_BASELINE=34400
TTE_INPUT_MODE="constant-phase-discriminator --threshold=10 --duration=1 --cool-off=0"
DIGITIZERS="-d4 -d5 -d6 -d4 -d8 -d9 -d10 -d11"
NEXUS_OUTPUT_PATH="Output/HiFi"

. ./libs/lib.sh
. ./tests/tests.sh

docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker-no-pipeline up -d

run_persistant_components

#kill_persistant_components

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker-no-pipeline down
