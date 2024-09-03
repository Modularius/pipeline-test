OTEL_ENDPOINT="http://localhost:4317/v1/traces"
#OTEL_ENDPOINT="http://146.199.207.182:4317/v1/traces"

RUST_LOG_OFF=tonic=off,h2=off,tokio_util=off,tower=off,hyper=off

. ./libs/lib_run_simulator.sh
. ./libs/lib_inputs.sh
. ./libs/lib_persistant.sh

kill_persistant_components() {
    pkill $PROCESS_EVENT_FORMATION
    pkill $PROCESS_WRITER
    pkill $PROCESS_AGGREGATOR
    pkill trace-archiver-
}

run_persistant_components() {
    kill_persistant_components
    run_trace_to_events
    run_aggregator
    run_nexus_writer
}