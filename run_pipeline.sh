#
#   Broker Settings
#
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

#
#   pkill names
#
PROCESS_WRITER=nexus-writer
PROCESS_AGGREGATOR=digitiser-aggre
PROCESS_EVENT_FORMATION=trace-to-events

#
#   Simulator Settings
#
INPUT=simulator
SIMULATOR_CONFIG_SOURCE="simulator_configs/test.json"

#
#   Event Formation Settings
#
#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_INPUT_MODE="fixed-threshold-discriminator --threshold=10 --duration=1 --cool-off=0"
TTE_POLARITY=positive
TTE_BASELINE=0

#
#   Digitiser Aggregator Settings
#
DIGITIZERS="-d4 -d5 -d6 -d8 -d9 -d10 -d11"

#
#   Nexus Writer Settings
#
NEXUS_OUTPUT_PATH="Output"

#
#   Otel Settings
#
OTEL_ENDPOINT="http://172.16.113.245:4317/v1/traces"
OTEL_LEVEL="--otel-level=info"
#OTEL_LEVEL="info"

#
#   Environment Variables and lib shells
#
export RUST_LOG=warn,digitiser_aggregator=warn,nexus_writer=warn,trace_to_events=warn,$RUST_LOG_OFF
export OTEL_BSP_MAX_QUEUE_SIZE=8192
. ./libs/lib.sh

run_persistant_components
run_trace_simulator
kill_persistant_components