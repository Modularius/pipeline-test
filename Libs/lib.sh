RUST_LOG_OFF=tonic=off,h2=off,tokio_util=off,tower=off,hyper=off

. ./Libs/lib_run_simulator.sh
. ./Libs/lib_inputs.sh
. ./Libs/lib_persistant.sh

build_digitiser_argument() {
    MAX_DIGITISER=$1
    DIGITIZERS=""
    for I in $(seq 0 1 $MAX_DIGITISER)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    echo "$DIGITIZERS"
}

kill_persistant_components() {
    pkill $PROCESS_EVENT_FORMATION
    pkill $PROCESS_WRITER
    pkill $PROCESS_AGGREGATOR
    pkill trace-archiver-

    podman rm --all --force
}

run_persistant_components() {
    #run_trace_to_events
    #run_aggregator
    run_nexus_writer
}

wait_for_input() {
    echo press any key to continue
    while true; do
        read -rsn1 key  # Read a single character silently
        if [[ -n "$key" ]]; then
            break  # Exit the loop if a key is pressed
        fi
    done
}