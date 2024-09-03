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
TTE_INPUT_MODE="fixed-threshold-discriminator --threshold=50 --duration=1 --cool-off=0"
NEXUS_OUTPUT_PATH="Output/HiFi"

. ./libs/lib.sh
. ./tests/tests.sh

docker compose --env-file ./configs/.env.hifi -f "./configs/docker-compose.yaml" --profile=all down
docker compose --env-file ./configs/.env.hifi -f "./configs/docker-compose.yaml" --profile=no-broker up -d
docker compose --env-file ./configs/.env.hifi -f "./configs/docker-compose.yaml" --profile=pipeline up -d


i=0
while :
do
    send_run_start DeadRun$i HiFi
    sleep 100
    send_run_stop DeadRun$i HiFi
    ((i++))
done
#docker compose --env-file ./configs/.env.hifi -f "./configs/docker-compose.yaml" --profile=no-broker down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=pipeline down
