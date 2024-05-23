run_full_test() {
    BROKER=$1
    INPUT=$2
    #TTE_INPUT_MODE=$3

    #kill_processes

    echo "--" "Run-Simulation Test"

    #run_trace_to_events $BROKER "trace-reader" "$TTE_INPUT_MODE" $TRACE_TOPIC $DAT_EVENT_TOPIC "trace-to-events" "127.0.0.1:9091"
    #run_aggregator $BROKER "-d1 -d2 -d3 -d4" $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC "digitiser-aggregator"
    #run_nexus_writer $BROKER $FRAME_EVENT_TOPIC $CONTROL_TOPIC

    #echo "--" "Finished Executing Persistent Tool"

    echo "--" "First Test"
    
    RunName=MyFirstTest
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC

    echo "--" "--" "Sending Log Data"
    send_logdata $BROKER $CONTROL_TOPIC Double "float64" "84"
    send_logdata $BROKER $CONTROL_TOPIC Double "float64" "423"
    send_logdata $BROKER $CONTROL_TOPIC Double "float64" "0"

    send_logdata $BROKER $CONTROL_TOPIC Float "float32" "84"
    send_logdata $BROKER $CONTROL_TOPIC Float "float32" "423"
    send_logdata $BROKER $CONTROL_TOPIC Float "float32" "0"

    send_logdata $BROKER $CONTROL_TOPIC Byte "int8" "84"
    send_logdata $BROKER $CONTROL_TOPIC Byte "int8" "123"
    send_logdata $BROKER $CONTROL_TOPIC Byte "int8" "0"

    send_logdata $BROKER $CONTROL_TOPIC Short "int16" "84"
    send_logdata $BROKER $CONTROL_TOPIC Short "int16" "423"
    send_logdata $BROKER $CONTROL_TOPIC Short "int16" "0"

    send_logdata $BROKER $CONTROL_TOPIC Int "int32" "84"
    send_logdata $BROKER $CONTROL_TOPIC Int "int32" "423"
    send_logdata $BROKER $CONTROL_TOPIC Int "int32" "0"

    send_logdata $BROKER $CONTROL_TOPIC Long "int64" "84"
    send_logdata $BROKER $CONTROL_TOPIC Long "int64" "423"
    send_logdata $BROKER $CONTROL_TOPIC Long "int64" "0"

    send_logdata $BROKER $CONTROL_TOPIC UByte "uint8" "84"
    send_logdata $BROKER $CONTROL_TOPIC UByte "uint8" "203"
    send_logdata $BROKER $CONTROL_TOPIC UByte "uint8" "0"

    send_logdata $BROKER $CONTROL_TOPIC UShort "uint16" "84"
    send_logdata $BROKER $CONTROL_TOPIC UShort "uint16" "423"
    send_logdata $BROKER $CONTROL_TOPIC UShort "uint16" "0"

    send_logdata $BROKER $CONTROL_TOPIC UInt "uint32" "84"
    send_logdata $BROKER $CONTROL_TOPIC UInt "uint32" "423"
    send_logdata $BROKER $CONTROL_TOPIC UInt "uint32" "0"

    send_logdata $BROKER $CONTROL_TOPIC ULong "uint64" "84"
    send_logdata $BROKER $CONTROL_TOPIC ULong "uint64" "423"
    send_logdata $BROKER $CONTROL_TOPIC ULong "uint64" "0"

    
    echo "--" "--" "Sending SeLogs"
    send_selog $BROKER $CONTROL_TOPIC Double "float64" "0 5 34"
    send_selog $BROKER $CONTROL_TOPIC Float "float32" "36 0.51"
    send_selog $BROKER $CONTROL_TOPIC Byte "int8" "36 51"
    send_selog $BROKER $CONTROL_TOPIC Short "int16" "36 51"
    send_selog $BROKER $CONTROL_TOPIC Int "int32" "36 51"
    send_selog $BROKER $CONTROL_TOPIC Long "int64" "36 51"
    send_selog $BROKER $CONTROL_TOPIC UByte "uint8" "36 51"
    send_selog $BROKER $CONTROL_TOPIC UShort "uint16" "36 51"
    send_selog $BROKER $CONTROL_TOPIC UInt "uint32" "36 51"
    send_selog $BROKER $CONTROL_TOPIC ULong "uint64" "36 51"

    echo "--" "--" "Sending Alarms"
    send_alarm $BROKER $CONTROL_TOPIC "Short" "OK" "Everything seems to be within Normal Parameters"
    send_alarm $BROKER $CONTROL_TOPIC "Short" "MINOR" "Great Scott!"
    send_alarm $BROKER $CONTROL_TOPIC "Short" "MAJOR" "Resonance Cascade"
    send_alarm $BROKER $CONTROL_TOPIC "Short" "INVALID" "Xen Invasion"

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator $BROKER $TRACE_TOPIC

    sleep 3
    send_run_stop $BROKER $RunName $CONTROL_TOPIC
    echo "--" "Finished"

    echo "--" "Second Test"

    RunName=MySecondTest
    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC

    echo "--" "--" "Sending Log Data"
    send_logdata $BROKER $CONTROL_TOPIC Double "float64" "423"
    send_logdata $BROKER $CONTROL_TOPIC Float "float32" "423"
    send_logdata $BROKER $CONTROL_TOPIC Byte "int8" "84"
    send_logdata $BROKER $CONTROL_TOPIC Short "int16" "84"
    send_logdata $BROKER $CONTROL_TOPIC Int "int32" "84"
    send_logdata $BROKER $CONTROL_TOPIC Long "int64" "423"
    send_logdata $BROKER $CONTROL_TOPIC UByte "uint8" "0"
    send_logdata $BROKER $CONTROL_TOPIC UShort "uint16" "0"
    send_logdata $BROKER $CONTROL_TOPIC UInt "uint32" "423"
    send_logdata $BROKER $CONTROL_TOPIC ULong "uint64" "423"

    send_selog $BROKER $CONTROL_TOPIC Short "int16" "36 51"
    send_alarm $BROKER $CONTROL_TOPIC "Short" "OK" "Everything seems to be within Normal Parameters"
    send_alarm $BROKER $CONTROL_TOPIC "Short" "MINOR" "Great Scott!"
    send_alarm $BROKER $CONTROL_TOPIC "Short" "MAJOR" "Resonance Cascade"
    send_alarm $BROKER $CONTROL_TOPIC "Short" "INVALID" "Xen Invasion"

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator $BROKER $TRACE_TOPIC
    
    sleep 3
    send_run_stop $BROKER $RunName $CONTROL_TOPIC

    echo "--" "Finished"
}