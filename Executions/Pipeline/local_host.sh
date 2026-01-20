####
# All shells in Executions/Pipeline have the following format:
#   execution_pipeline_init_environment()
#   execution_pipeline_init_broker()
#   execution_pipeline_clean_files()
#   execution_pipeline_init()

. ./Libs/lib.sh

set -a

#export OTEL_BSP_MAX_QUEUE_SIZE=8192

### Only Called Globally.
execution_pipeline_init_environment() {
    set -a

    ### Set Local Host
    g_LOCALHOST=localhost
}

### Only Called Globally.
execution_pipeline_init_broker_settings() {
    set -a

    g_NUM_DIGITISERS=8
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))
    . ./Settings/Local/Broker.sh
}

### Only called from "Executions/Run/"
# PARAMETERS:
##  g_NUM_DIGITISERS: number of digitisers in the run.
##  g_RUN_NAME: the name to use for the run.
##  g_SIMULATOR_CONFIG_SOURCE: the path for the simulation, relative to "Simulations/"
execution_pipeline_init_run() {
    set -a
    g_NUM_DIGITISERS=$1;shift;
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))

    g_RUN_NAME=$1;shift;
    
    g_SIMULATOR_CONFIG_SOURCE="Simulations/$1";shift;
    
    MAX_DIGITISER=$g_MAX_DIGITISER
    NUM_DIGITISERS=$g_NUM_DIGITISERS
    RUN_NAME=$g_RUN_NAME

    run_trace_simulator "$g_SIMULATOR" $g_BROKER \
    $g_CONTROL_TOPIC $g_LOGS_TOPIC $g_SELOGS_TOPIC $g_ALARMS_TOPIC \
        $g_TRACE_TOPIC $g_DAT_EVENT_TOPIC $g_FRAME_EVENT_TOPIC \
        $g_OBSV_ADDRESS_SIM "$g_OTEL_ENDPOINT" \
        $g_SIMULATOR_CONFIG_SOURCE
}

### Only Called Globally.
execution_pipeline_clean_files() {
    rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/archive/incoming/local/*.nxs
    rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/*.nxs
    rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/completed/*.nxs
}

### Only Called Globally.
execution_pipeline_kill() {
    pkill --signal SIGINT $g_PROCESS_EVENT_FORMATION
    pkill --signal SIGINT $g_PROCESS_WRITER
    pkill --signal SIGINT $g_PROCESS_AGGREGATOR
}

### Only Called Globally.
execution_pipeline_init() {
    run_trace_to_events
    run_aggregator
    run_nexus_writer
}