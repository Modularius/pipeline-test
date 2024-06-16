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
DIGITIZERS="-d4 -d5 -d6 -d8 -d9 -d10 -d11"
NEXUS_OUTPUT_PATH="Output/HiFi"

OTEL_LEVEL="--otel-level=off"

. ./libs/lib.sh
. ./tests/tests.sh

docker compose --env-file ./configs/.env.hifi -f "./configs/docker-compose.yaml" --profile=all down
docker compose --env-file ./configs/.env.hifi -f "./configs/docker-compose.yaml" --profile=no-broker up -d

export RUST_LOG=info,digitiser_aggregator=off,nexus_writer=off,trace_to_events=off,$RUST_LOG_OFF

i=0
while :
do
#run_persistant_components
run_nexus_writer "nexus-writer"
sleep 1
send_run_start FrameEventRun$i HiFi "--time 2024-05-30T02:14:29.0Z"
send_run_stop FrameEventRun$i HiFi "--time 2024-06-01T12:49:02.0Z"
sleep 100
kill_persistant_components
sleep 1
((i++))
done

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker-no-pipeline down
