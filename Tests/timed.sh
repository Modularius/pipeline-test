run_timed_test() {

    echo "--" "Run-Simulation Test"

    echo "--" "First Test"
    RunName=MyFirstTest
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator

    sleep 10
    send_run_stop $RunName
    echo "--" "Finished"
    
}