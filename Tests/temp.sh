run_temp_test() {
    echo "--" "Finished Executing Persistent Tool"

    RunName=Channels600Test
    echo "--" "$RunName Test"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/data5.json"
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator

    sleep 4
    send_run_stop $RunName
    echo "--" "Finished"
    
    RunName=Channels800Test
    echo "--" "$RunName Test"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/data6.json"
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator

    sleep 4
    send_run_stop $RunName
    echo "--" "Finished"
    
    RunName=Channels1000Test
    echo "--" "$RunName Test"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/data7.json"
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    run_trace_simulator

    sleep 4
    send_run_stop $RunName
    echo "--" "Finished"
}