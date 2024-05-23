OTEL_ENDPOINT="http://localhost:4317/v1/traces"

. ./libs/lib_run_simulator.sh
. ./libs/lib_inputs.sh
. ./libs/lib_persistant.sh

kill_persistant_components() {
    pkill trace-to-events
    pkill nexus-writer
    pkill digitiser-aggre
    pkill trace-archiver-
}

run_persistant_components() {
    kill_persistant_components
    run_trace_to_events "trace-to-events" "127.0.0.1:9091"
    run_aggregator "digitiser-aggregator"
    run_nexus_writer "nexus-writer"
}