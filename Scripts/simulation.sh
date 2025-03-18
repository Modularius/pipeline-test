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
    
    MAX_DIGITISER=$g_MAX_DIGITISER
    NUM_DIGITISERS=$g_NUM_DIGITISERS
    RUN_NAME=$g_RUN_NAME
    export MAX_DIGITISER
    export NUM_DIGITISERS
    export RUN_NAME

    run_trace_simulator "$g_SIMULATOR" \
        $g_BROKER $g_CONTROL_TOPIC $g_TRACE_TOPIC $g_DAT_EVENT_TOPIC $g_FRAME_EVENT_TOPIC \
        $g_OBSV_ADDRESS_SIM "$g_OTEL_ENDPOINT" \
        $g_SIMULATOR_CONFIG_SOURCE
}

rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/archive/incoming/local/*.nxs
rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/temp/*.nxs
rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/completed/*.nxs

g_PIPELINE_NAME=local
run_persistant_components
sleep 2

execute_run 8 SelogTest "Simulations/for_anthony.json"

