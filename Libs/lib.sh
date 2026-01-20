g_RUST_LOG_OFF=tonic=off,h2=off,tokio_util=off,tower=off,hyper=off

. ./Libs/lib_run_simulator.sh
. ./Libs/lib_inputs.sh
. ./Libs/lib_persistant.sh

echo_title() {
    echo -e "\033[31m\033[1m\033[4m$1\033[0m"
}

echo_subtitle() {
    echo -e  "    \033[32m\033[1m\033[4m$1\033[0m"
}

echo_heading_item() {
    echo -e "        \033[36m\033[1m\033[4m$1\033[0m: $2"
}

kill_persistant_components() {
    pkill --signal SIGINT $g_PROCESS_EVENT_FORMATION
    pkill --signal SIGINT $g_PROCESS_WRITER
    pkill --signal SIGINT $g_PROCESS_AGGREGATOR
}

run_persistant_components() {
    kill_persistant_components
    run_trace_to_events
    run_aggregator
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