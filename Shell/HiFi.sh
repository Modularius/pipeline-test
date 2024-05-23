. ./.vscode/Benchmark/Shell/lib.sh
. ./.vscode/Benchmark/Shell/kill.sh


cargo build --release

BROKER="130.246.55.29:9092"
TRACE_TOPIC=daq-traces-in
DAT_EVENT_TOPIC=daq-events-in
FRAME_EVENT_TOPIC=ics-_events
CONTROL_TOPIC=ics-control-change
LOGS_TOPIC=ics-metadata
SELOGS_TOPIC=ics-metadata
ALARMS_TOPIC=ics-alarms

TTE_INPUT_MODE="constant-phase-discriminator --threshold=10 --duration=1 --cool-off=0"
#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"


run_trace_to_events $BROKER "trace-reader" "$TTE_INPUT_MODE" $TRACE_TOPIC $DAT_EVENT_TOPIC "trace-to-events" "127.0.0.1:9091"
run_aggregator $BROKER "-d1 -d2 -d3 -d4" $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC "digitiser-aggregator"
run_nexus_writer $BROKER $FRAME_EVENT_TOPIC $CONTROL_TOPIC
