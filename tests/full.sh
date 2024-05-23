run_full_test() {

    echo "--" "Run-Simulation Test"

    echo "--" "First Test"
    
    RunName=MyFirstTest
    send_run_start $RunName MuSR

    echo "--" "--" "Sending Log Data"
    send_logdata Double "float64" "84"
    send_logdata Double "float64" "423"
    send_logdata Double "float64" "0"

    send_logdata Float "float32" "84"
    send_logdata Float "float32" "423"
    send_logdata Float "float32" "0"

    send_logdata Byte "int8" "84"
    send_logdata Byte "int8" "123"
    send_logdata Byte "int8" "0"

    send_logdata Short "int16" "84"
    send_logdata Short "int16" "423"
    send_logdata Short "int16" "0"

    send_logdata Int "int32" "84"
    send_logdata Int "int32" "423"
    send_logdata Int "int32" "0"

    send_logdata Long "int64" "84"
    send_logdata Long "int64" "423"
    send_logdata Long "int64" "0"

    send_logdata UByte "uint8" "84"
    send_logdata UByte "uint8" "203"
    send_logdata UByte "uint8" "0"

    send_logdata UShort "uint16" "84"
    send_logdata UShort "uint16" "423"
    send_logdata UShort "uint16" "0"

    send_logdata UInt "uint32" "84"
    send_logdata UInt "uint32" "423"
    send_logdata UInt "uint32" "0"

    send_logdata ULong "uint64" "84"
    send_logdata ULong "uint64" "423"
    send_logdata ULong "uint64" "0"

    
    echo "--" "--" "Sending SeLogs"
    send_selog Double "float64" "0 5 34"
    send_selog Float "float32" "36 0.51"
    send_selog Byte "int8" "36 51"
    send_selog Short "int16" "36 51"
    send_selog Int "int32" "36 51"
    send_selog Long "int64" "36 51"
    send_selog UByte "uint8" "36 51"
    send_selog UShort "uint16" "36 51"
    send_selog UInt "uint32" "36 51"
    send_selog ULong "uint64" "36 51"

    echo "--" "--" "Sending Alarms"
    send_alarm "Short" "OK" "Everything seems to be within Normal Parameters"
    send_alarm "Short" "MINOR" "Great Scott!"
    send_alarm "Short" "MAJOR" "Resonance Cascade"
    send_alarm "Short" "INVALID" "Xen Invasion"

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator

    sleep 3
    send_run_stop $RunName
    echo "--" "Finished"

    echo "--" "Second Test"

    RunName=MySecondTest
    send_run_start $RunName MuSR

    echo "--" "--" "Sending Log Data"
    send_logdata Double "float64" "423"
    send_logdata Float "float32" "423"
    send_logdata Byte "int8" "84"
    send_logdata Short "int16" "84"
    send_logdata Int "int32" "84"
    send_logdata Long "int64" "423"
    send_logdata UByte "uint8" "0"
    send_logdata UShort "uint16" "0"
    send_logdata UInt "uint32" "423"
    send_logdata ULong "uint64" "423"

    send_selog Short "int16" "36 51"
    send_alarm "Short" "OK" "Everything seems to be within Normal Parameters"
    send_alarm "Short" "MINOR" "Great Scott!"
    send_alarm "Short" "MAJOR" "Resonance Cascade"
    send_alarm "Short" "INVALID" "Xen Invasion"

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator
    
    sleep 3
    send_run_stop $RunName 

    echo "--" "Finished"
}