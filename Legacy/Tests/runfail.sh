run_stop_first_test() {
    BROKER=$1
    INPUT=$2
    TTE_INPUT_MODE=$3

    kill_processes

    echo "--" "Run-Stop Test"

    run_nexus_writer $BROKER $FRAME_EVENT_TOPIC $CONTROL_TOPIC
    
    RunName=MyOtherTest
    send_run_stop $BROKER $RunName $CONTROL_TOPIC

    echo "--" "Finished"
}