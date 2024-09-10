BROKER="130.246.55.29:9092"
TRACE_TOPIC=daq-traces-in
DAT_EVENT_TOPIC=daq-events
FRAME_EVENT_TOPIC=frame-events
CONTROL_TOPIC=ics-control-change
LOGS_TOPIC=ics-metadata
SELOGS_TOPIC=ics-metadata
ALARMS_TOPIC=ics-alarms

GROUP_WRITER=nexus-writer
GROUP_AGGREGATOR=digitiser-aggregator
GROUP_EVENT_FORMATION=trace-to-events

PROCESS_WRITER=nexus-writer
PROCESS_AGGREGATOR=digitiser-aggre
PROCESS_EVENT_FORMATION=trace-to-events

#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_POLARITY=positive
TTE_BASELINE=0
TTE_INPUT_MODE="fixed-threshold-discriminator --threshold=100 --duration=1 --cool-off=0"
DIGITIZERS="-d4 -d5 -d6 -d7 -d8 -d9 -d10 -d11"
NEXUS_OUTPUT_PATH="Output/HiFi"

OTEL_LEVEL_EVENT_FORMATION="--otel-level=off"
OTEL_LEVEL_AGGREGATOR="--otel-level=off"
OTEL_LEVEL_WRITER="--otel-level=off"
OTEL_LEVEL_SIM="--otel-level=off"

. ./libs/lib.sh
. ./tests/tests.sh

#docker compose --env-file ./configs/.env.hifi -f "./configs/docker-compose.yaml" --profile=all down
#docker compose --env-file ./configs/.env.hifi -f "./configs/docker-compose.yaml" --profile=no-broker up -d

export RUST_LOG=info,digitiser_aggregator=off,nexus_writer=off,trace_to_events=off,$RUST_LOG_OFF

run_persistant_components
#sleep 1
# i=0
# while :
# do
#     echo Beginning
#     send_run_start FrameEventRun$i HiFi "--time 2020-07-30T02:14:29.0Z"
#     sleep 5
#     send_run_stop FrameEventRun$i "--time 2025-10-01T12:49:02.0Z"
#     sleep 1
#     ((i++))
# done

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker-no-pipeline down
