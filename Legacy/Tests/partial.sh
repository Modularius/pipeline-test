run_partial_test() {
    echo "--" "Finished Executing Persistent Tool"

    echo "--" "First Test"

    RunName=TempPartialTest
    send_run_start $RunName MuSR
    sleep 1

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator

    sleep 4
    send_run_stop $RunName
    echo "--" "Finished"

}