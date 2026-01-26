####
# All shells in Executions have the following format:
#   execution_init_environment()
#   execution_init_broker()
#   execution_run()

. ./Libs/lib.sh

set -a

execute_run() {
    g_NUM_DIGITISERS=$1;shift;
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))

    g_RUN_NAME=$1;shift;
    export g_MAX_DIGITISER
    export g_NUM_DIGITISERS
    export g_RUN_NAME
    
    g_SIMULATOR_CONFIG_SOURCE=$1;shift;
    
    MAX_DIGITISER=$g_MAX_DIGITISER
    NUM_DIGITISERS=$g_NUM_DIGITISERS
    RUN_NAME=$g_RUN_NAME
    export MAX_DIGITISER
    export NUM_DIGITISERS
    export RUN_NAME

    run_trace_simulator "$g_SIMULATOR" $g_BROKER \
    $g_CONTROL_TOPIC $g_LOGS_TOPIC $g_SELOGS_TOPIC $g_ALARMS_TOPIC \
        $g_TRACE_TOPIC $g_DAT_EVENT_TOPIC $g_FRAME_EVENT_TOPIC \
        $g_OBSV_ADDRESS_SIM "$g_OTEL_ENDPOINT" \
        $g_SIMULATOR_CONFIG_SOURCE
}

execution_run() {
    #rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/archive/incoming/local/*.nxs
    #rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/*.nxs
    #rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/completed/*.nxs

    #g_PIPELINE_NAME=local
    echo_subtitle "Executing Host Pipeline"
    run_trace_to_events
    run_aggregator
    run_nexus_writer

    sleep 3

    echo_subtitle "Executing Run"

    execute_run 8 ShortTest "Simulations/Tests/SanityChecking/test3.json"
    
    echo_subtitle "Run Execution Completed"
    #execute_run 8 Beep "Simulations/Deterministic.json"
    #sleep 7
    #export RUN_NAME_1=TwoRunTest1
    #export RUN_NAME_2=TwoRunTest2
    #execute_run 8 TwoRunTest "Simulations/Tests/SanityChecking/two_runs_and_selogs.json"
    #sleep 7
    #execute_run 8 DuplicateDigitisers "Simulations/Tests/DuplicateDigitiserMessages/test.json"
    #sleep 7
    #execute_run 8 Test2 "Simulations/Tests/IncompleteFrames/test1.json"
    #sleep 7
    #execute_run 8 Test3 "Simulations/Tests/IncompleteFrames/test2.json"
    #sleep 7
    #execute_run 8 AlarmTest "Simulations/Tests/Logs/alarm.json"
    #sleep 7
    #execute_run 8 RunLogTest "Simulations/Tests/Logs/runlog.json"
    #sleep 7
    #execute_run 8 SELogTest "Simulations/Tests/Logs/selog.json"
    #sleep 7
    #execute_run 8 SELogAndAlarmTest "Simulations/Tests/Logs/selog_and_alarm.json"
    #docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
    #docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker up -d   
}