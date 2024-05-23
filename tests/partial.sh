run_partial_test() {
    BROKER="$1"
    INPUT="$2"
    TTE_INPUT_MODE="$3"

    echo "--" "Run-Simulation Test"

    run_trace_to_events $BROKER "trace-reader" "$TTE_INPUT_MODE" $TRACE_TOPIC $DAT_EVENT_TOPIC "trace-to-events" "127.0.0.1:9091"
    run_aggregator $BROKER "-d1 -d2 -d3 -d4" $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC "digitiser-aggregator"
    run_nexus_writer $BROKER $FRAME_EVENT_TOPIC $CONTROL_TOPIC

    echo "--" "Finished Executing Persistent Tool"

    echo "--" "First Test"
    
    RunName=MyFirstTest
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator $BROKER $TRACE_TOPIC

    sleep 3
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    echo "--" "Finished"

}