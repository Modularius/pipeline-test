run_X_type_in_Y_type_logdata_test() {
    BROKER=$1
    CORRECT_TYPE="$2"
    WRONG_TYPE="$3"

    kill_processes

    echo "--" "Run-Simulation Log Error Test"

    run_nexus_writer $BROKER $FRAME_EVENT_TOPIC $CONTROL_TOPIC
    
    RunName=MyOtherTest

    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC

    send_logdata $BROKER $CONTROL_TOPIC Test $CORRECT_TYPE "1"
    send_logdata $BROKER $CONTROL_TOPIC Test $WRONG_TYPE "2"

    sleep 3
    send_run_stop $BROKER $RunName $CONTROL_TOPIC

    echo "--" "Finished"
}

run_X_type_in_Y_type_selog_test() {
    BROKER=$1
    CORRECT_TYPE="$2"
    WRONG_TYPE="$3"

    kill_processes

    echo "--" "Run-Simulation Log Error Test"

    run_nexus_writer $BROKER $FRAME_EVENT_TOPIC $CONTROL_TOPIC
    
    RunName=MyOtherTest

    send_run_start $BROKER $RunName MuSR $CONTROL_TOPIC

    send_selog $BROKER $CONTROL_TOPIC Test $CORRECT_TYPE "1 2 3"
    send_selog $BROKER $CONTROL_TOPIC Test $WRONG_TYPE "2 3 4"

    sleep 3
    send_run_stop $BROKER $RunName $CONTROL_TOPIC

    echo "--" "Finished"
}