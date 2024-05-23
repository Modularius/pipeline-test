. ./.vscode/Benchmark/Shell/lib.sh
. ./.vscode/Benchmark/Shell/Tests/full.sh
. ./.vscode/Benchmark/Shell/Tests/partial.sh
. ./.vscode/Benchmark/Shell/Tests/typetests.sh
. ./.vscode/Benchmark/Shell/Tests/benchmark.sh


cargo build --release

BROKER="localhost:19092"
TRACE_TOPIC=Traces
DAT_EVENT_TOPIC=Events
FRAME_EVENT_TOPIC=FrameEvents
CONTROL_TOPIC=Controls
LOGS_TOPIC=Logs
SELOGS_TOPIC=SELogs
ALARMS_TOPIC=Alarms

#BROKER="130.246.55.29:9092"
#TRACE_TOPIC=daq-traces-in
#DAT_EVENT_TOPIC=daq-events-in
#FRAME_EVENT_TOPIC=ics-_events
#CONTROL_TOPIC=ics-control-change
#LOGS_TOPIC=ics-metadata
#SELOGS_TOPIC=ics-metadata
#ALARMS_TOPIC=ics-alarms

#cargo run --bin kafka-daq-report -- --broker 130.246.55.29:9092 --group=vis-3 --trace-topic=daq-traces-in
#cargo run --bin trace-archiver-hdf5 -- --broker 130.246.55.29:9092 --group=vis-1 --trace-topic=daq-traces-in --file "Trace.nxs" --digitizer-count 12


TTE_INPUT_MODE="constant-phase-discriminator --threshold=10 --duration=1 --cool-off=0"

run_full_test $BROKER simulator "$TTE_INPUT_MODE"
#advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10
