####
#   execution_pipeline_init_environment()
#   execution_pipeline_init_broker()
#   execution_pipeline_clean_files()
#   execution_pipeline_init()

. ./Libs/lib.sh

set -a

### Only Called Globally.
execution_pipeline_init_environment() {
    set -a

    ### Set Local Host
    g_LOCALHOST=localhost
    g_PROFILE=all
}

### Only Called Globally.
execution_pipeline_init_broker_settings() {
    set -a

    g_NUM_DIGITISERS=8
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))
    . ./Settings/Local/Broker.sh
}

#export OTEL_BSP_MAX_QUEUE_SIZE=8192

### Called Locally.
set_pipeline_local_variables() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;

    #
    # Set Local Variables
    #
    PIPELINE_NAME=${g_PIPELINE_NAME}${LOCAL_PIPELINE_NAME}
    
    # Broker Settings
    BROKER=${g_BROKER}
   
    TRACE_TOPIC=${g_TRACE_TOPIC}
    DAT_EVENT_TOPIC=${g_DAT_EVENT_TOPIC}
    FRAME_EVENT_TOPIC=${g_FRAME_EVENT_TOPIC}
    CONTROL_TOPIC=${g_CONTROL_TOPIC}
    LOGS_TOPIC=${g_LOGS_TOPIC}
    SELOGS_TOPIC=${g_SELOGS_TOPIC}
    ALARMS_TOPIC=${g_ALARMS_TOPIC}

    # Observability
    RUST_LOG=${g_RUST_LOG}
    OTEL_LEVEL=${g_OTEL_LEVEL}
    NO_COLOR=${g_NO_COLOR}

    OTEL_ENDPOINT=${g_OTEL_ENDPOINT}
}

# Called Locally.
set_persistant_pipeline_local_variables() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;

    GROUP_EVENT_FORMATION=${g_GROUP_EVENT_FORMATION}
    GROUP_AGGREGATOR=${g_GROUP_AGGREGATOR}
    GROUP_WRITER=${g_GROUP_WRITER}

    OBSV_ADDRESS_EVENT_FORMATION=${g_OBSV_ADDRESS_EVENT_FORMATION}
    OBSV_ADDRESS_AGGREGATOR=${g_OBSV_ADDRESS_AGGREGATOR}
    OBSV_ADDRESS_WRITER=${g_OBSV_ADDRESS_WRITER}
    
    OTEL_LEVEL_EVENT_FORMATION=${g_OTEL_LEVEL_EVENT_FORMATION}
    OTEL_LEVEL_AGGREGATOR=${g_OTEL_LEVEL_AGGREGATOR}
    OTEL_LEVEL_WRITER=${g_OTEL_LEVEL_WRITER}

    # Trace Source Dependent Event Formation Settings
    TTE_POLARITY=${g_TTE_POLARITY}
    TTE_BASELINE=${g_TTE_BASELINE}
    TTE_INPUT_MODE=${g_TTE_INPUT_MODE}
    TTE_BEGIN_THRESHOLD=${g_TTE_BEGIN_THRESHOLD}
    TTE_END_THRESHOLD=${g_TTE_END_THRESHOLD}
    TTE_BEGIN_DURATION=${g_TTE_BEGIN_DURATION}
    TTE_END_DURATION=${g_TTE_END_DURATION}
    TTE_COOLOFF=${g_TTE_COOLOFF}
    TTE_PEAK_MODE=${g_TTE_PEAK_MODE}
    TTE_PEAK_BASIS=${g_TTE_PEAK_BASIS}

    # Digitisers Expected from Broker
    DIGITISERS=${g_DIGITISERS}
    FRAME_TTL_MS=${g_FRAME_TTL_MS}

    # Output Path
    NEXUS_OUTPUT_PATH=${g_NEXUS_OUTPUT_PATH}_${LOCAL_PIPELINE_NAME}
    NEXUS_ARCHIVE_PATH=${g_NEXUS_ARCHIVE_PATH}_${LOCAL_PIPELINE_NAME}
    RUN_TTL_MS=${g_RUN_TTL_MS}
}

# Called Locally.
set_simulator_local_variables() {
    set -a
    
    RUN_NAME=$1;shift;

    MAX_DIGITISER=${g_MAX_DIGITISER}
    NUM_DIGITISERS=${g_NUM_DIGITISERS}

    OBSV_ADDRESS_SIM=${g_OBSV_ADDRESS_SIM}

    SIMULATOR_PATH="Simulations"
    SIMULATOR_SOURCE=$g_SIMULATOR_CONFIG_SOURCE
}

teardown_broker() {
    echo_subtitle "Removing Broker"
    podman-compose -f "Compose/redpanda.yml" -p "local_broker" down
}

deploy_broker() {
    echo_subtitle "Deploying Broker"
    podman-compose -f "Compose/redpanda.yml" -p "local_broker" up -d
}

### Only called from "Executions/Run/"
# PARAMETERS:
##  g_NUM_DIGITISERS: number of digitisers in the run.
##  g_RUN_NAME: the name to use for the run.
##  g_SIMULATOR_CONFIG_SOURCE: the path for the simulation, relative to "Simulations/"
execution_pipeline_init_run() {
    set -a

    echo_heading_item "Removing Simulator Container 'local'"

    podman-compose -f "Compose/simulator.yml" -p "local_simulator" down


    g_NUM_DIGITISERS=$1;shift;
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))

    g_RUN_NAME=$1;shift;
    
    g_SIMULATOR_CONFIG_SOURCE=$1;shift;
    
    MAX_DIGITISER=$g_MAX_DIGITISER
    NUM_DIGITISERS=$g_NUM_DIGITISERS
    RUN_NAME=$g_RUN_NAME

    #
    # Set Local Variables
    #
    set_pipeline_local_variables $g_PIPELINE_NAME
    set_simulator_local_variables $RUN_NAME

    cat Compose/simulator.template.yml | envsubst > Compose/simulator.yml
    echo_heading_item "Executing Simulator Container 'local_simulator'"
    podman-compose -f "Compose/simulator.yml" -p local_simulator up -d
}

### Only Called Globally.
execution_pipeline_clean_files() {
    rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/archive/incoming/local/*.nxs
    rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/*.nxs
    rm /home/ubuntu/SuperMuSRDataPipeline/pipeline-test/Output/local/completed/*.nxs
}

### Only Called Globally.
execution_pipeline_kill() {
    set -a

    echo_heading_item "Removing Pipeline($g_PROFILE) with name local"
    podman-compose -f Compose/pipeline.yml -p local --profile $g_PROFILE down
    echo_heading_item "Removing Simulator with name local_similator"
    podman-compose -f Compose/simulator.yml -p local_simulator down
}

### Only Called Globally.
execution_pipeline_init() {
    set -a

    echo_heading_item "Deploying Pipeline($g_PROFILE) with name local"

    set_pipeline_local_variables $g_PIPELINE_NAME
    set_persistant_pipeline_local_variables $g_PIPELINE_NAME
    
    cat Compose/pipeline.template.yml | envsubst > Compose/pipeline.yml
    podman-compose -f Compose/pipeline.yml -p "local" --profile $g_PROFILE up -d
}
