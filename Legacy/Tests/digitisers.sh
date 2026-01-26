run_digitiser_test() {

    echo "--" "Run-Digitiser Scaling Test"

    echo "--" "4 Digitisers"
    RunName=Four
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/FourDigis.json"
    DIGITIZERS=""
    for I in $(seq 0 1 3)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    run_trace_simulator

    sleep 1
    send_run_stop $RunName

    echo "--" "Finished 4 Digitisers"

    sleep 5
    run_persistant_components
    
    echo "--" "8 Digitisers"
    RunName=Eight
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/EightDigis.json"
    DIGITIZERS=""
    for I in $(seq 0 1 7)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    run_trace_simulator

    sleep 2
    send_run_stop $RunName

    echo "--" "Finished 8 Digitisers"

    sleep 5
    run_persistant_components
    
    echo "--" "16 Digitisers"
    RunName=Sixteen
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/SixteenDigis.json"
    DIGITIZERS=""
    for I in $(seq 0 1 15)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    run_trace_simulator

    sleep 4
    send_run_stop $RunName

    echo "--" "Finished 16 Digitisers"

    sleep 5
    run_persistant_components
    
    echo "--" "30 Digitisers"
    RunName=Thirty
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/ThirtyDigis.json"
    DIGITIZERS=""
    for I in $(seq 0 1 29)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    run_trace_simulator

    sleep 8
    send_run_stop $RunName

    echo "--" "Finished 30 Digitisers"

    sleep 5
    run_persistant_components
    
    echo "--" "60 Digitisers"
    RunName=Sixty
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/SixtyDigis.json"
    DIGITIZERS=""
    for I in $(seq 0 1 59)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    run_trace_simulator

    sleep 16
    send_run_stop $RunName

    echo "--" "Finished 60 Digitisers"

    sleep 5
    run_persistant_components
    
    echo "--" "100 Digitisers"
    RunName=Hundred
    send_run_start $RunName MuSR

    echo "--" "--" "Executing Input Generator"
    SIMULATOR_CONFIG_SOURCE="simulator_configs/OneHundredDigis.json"
    DIGITIZERS=""
    for I in $(seq 0 1 99)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    run_trace_simulator

    sleep 32
    send_run_stop $RunName

    echo "--" "Finished 100 Digitisers"

    echo "--" "Finished"
    
}