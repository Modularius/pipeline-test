run_benchmark_test() {
    BROKER=$1
    INPUT=$2
    TTE_INPUT_MODE=$3

    kill_processes

    echo "--" "Run-Simulation Test"

    run_trace_to_events $BROKER "trace-reader" "$TTE_INPUT_MODE" $TRACE_TOPIC $DAT_EVENT_TOPIC "trace-to-events" "127.0.0.1:9091"
    run_aggregator $BROKER "-d1 -d2 -d3 -d4" $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC "digitiser-aggregator"
    run_nexus_writer $BROKER $FRAME_EVENT_TOPIC $CONTROL_TOPIC

    echo "--" "Finished Executing Persistent Tool"

    echo "--" "Tests"
    
    RunName=Test1
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC
    run_trace_simulator $BROKER $TRACE_TOPIC
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    
    RunName=Test2
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC
    run_trace_simulator $BROKER $TRACE_TOPIC
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    
    RunName=Test3
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC
    run_trace_simulator $BROKER $TRACE_TOPIC
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    
    RunName=Test4
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC
    run_trace_simulator $BROKER $TRACE_TOPIC
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    
    RunName=Test5
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC
    run_trace_simulator $BROKER $TRACE_TOPIC
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    
    RunName=Test6
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC
    run_trace_simulator $BROKER $TRACE_TOPIC
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    
    RunName=Test7
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC
    run_trace_simulator $BROKER $TRACE_TOPIC
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    echo "--" "Finished"

    sleep 3

    echo "--" "All Finished"
}