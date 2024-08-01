BROKER="localhost:19092"
TRACE_TOPIC=Traces
DAT_EVENT_TOPIC=Events
FRAME_EVENT_TOPIC=FrameEvents
CONTROL_TOPIC=Controls
LOGS_TOPIC=Logs
SELOGS_TOPIC=SELogs
ALARMS_TOPIC=Alarms

INPUT=simulator
SIMULATOR_CONFIG_SOURCE="simulator_configs/test.json"
#SIMULATOR_CONFIG_SOURCE="simulator_configs/full_frame.json"
#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_POLARITY=positive
TTE_BASELINE=0
TTE_INPUT_MODE="fixed-threshold-discriminator --threshold=10 --duration=1 --cool-off=0"
DIGITIZERS=""
for I in $(seq 0 1 127)
do
    DIGITIZERS=$DIGITIZERS" -d$I"
done
#DIGITIZERS="-d0 -d1"
#DIGITIZERS="-d0"
NEXUS_OUTPUT_PATH="Output/Local"

OTEL_LEVEL="--otel-level=info"
#OTEL_LEVEL="info"

. ./libs/lib.sh

kill_persistant_components

export RUST_LOG=info,digitiser_aggregator=warn,nexus_writer=warn,trace_to_events=off,$RUST_LOG_OFF

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
#sudo docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=broker up -d

run_persistant_components

sleep 2

run_trace_simulator

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-pipeline down
