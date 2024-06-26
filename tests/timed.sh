run_timed_test() {

    echo "--" "Run-Simulation Test"

    echo "--" "First Test"
    
    RunName=MyFirstTest
    send_run_start $RunName MuSR

    echo "--" "--" "Sending Log Data"
    send_logdata Double "float64" "84"
    send_logdata Double "float64" "423"
    send_logdata Double "float64" "0"

    
    echo "--" "--" "Sending SeLogs"
    send_selog Short "float64" "0 5 34"

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

    sleep 3
    
}