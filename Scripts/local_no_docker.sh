. ./Libs/lib.sh

#export OTEL_BSP_MAX_QUEUE_SIZE=8192

execute_run() {
    g_NUM_DIGITISERS=$1;shift;
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))

    g_RUN_NAME=$1;shift;
    export g_MAX_DIGITISER
    export g_NUM_DIGITISERS
    export g_RUN_NAME
    
    g_SIMULATOR_CONFIG_SOURCE=$1;shift;

    #g_DIGITISERS="-d0 -d1 -d2 -d3 -d4 -d5 -d6 -d7"
    #-d$(seq -s"," 0 $g_MAX_DIGITISER)

    #mkdir $g_NEXUS_ARCHIVE_PATH --mode=766
    #mkdir $g_NEXUS_OUTPUT_PATH --mode=766

    #kill_persistant_components

    #sleep 1

    #g_PIPELINE_NAME=local1-${g_RUN_NAME}
    #run_persistant_components

    #sleep 1

    
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

#rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/archive/incoming/local/*.nxs
#rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/*.nxs
#rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/completed/*.nxs

#g_PIPELINE_NAME=local
run_persistant_components
sleep 3

execute_run 8 ShortTest "Simulations/Tests/SanityChecking/test3.json"
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
