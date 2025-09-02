
#export OTEL_BSP_MAX_QUEUE_SIZE=8192
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
    TTE_FTD_THRESHOLD=${g_TTE_FTD_THRESHOLD}
    TTE_FTD_DURATION=${g_TTE_FTD_DURATION}
    TTE_FTD_COOLOFF=${g_TTE_FTD_COOLOFF}

    # Digitisers Expected from Broker
    DIGITISERS=${g_DIGITISERS}
    FRAME_TTL_MS=${g_FRAME_TTL_MS}

    # Output Path
    NEXUS_OUTPUT_PATH=${g_NEXUS_OUTPUT_PATH}_${LOCAL_PIPELINE_NAME}
    NEXUS_ARCHIVE_PATH=${g_NEXUS_ARCHIVE_PATH}_${LOCAL_PIPELINE_NAME}
    RUN_TTL_MS=${g_RUN_TTL_MS}
}

set_simulator_local_variables() {
    set -a
    
    RUN_NAME=$1;shift;

    MAX_DIGITISER=${g_MAX_DIGITISER}
    NUM_DIGITISERS=${g_NUM_DIGITISERS}

    OBSV_ADDRESS_SIM=${g_OBSV_ADDRESS_SIM}

    SIMULATOR_PATH="Simulations"
    SIMULATOR_SOURCE="test.json"
}

teardown_pipeline() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;
    PROFILE=$1;shift;

    podman-compose -f Compose/pipeline.yml -p ${LOCAL_PIPELINE_NAME} --profile $PROFILE down
}

teardown_broker() {
    podman-compose -f "Compose/redpanda.yml" -p "local_broker" down
}

deploy_broker() {
    podman-compose -f "Compose/redpanda.yml" -p "local_broker" up -d
}

deploy_pipeline() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift; 
    PROFILE=$1;shift;

    echo deploying pipeline $LOCAL_PIPELINE_NAME

    set_pipeline_local_variables $LOCAL_PIPELINE_NAME
    set_persistant_pipeline_local_variables $LOCAL_PIPELINE_NAME
    
    cat Compose/pipeline.template.yml | envsubst > Compose/pipeline.yml
    podman-compose -f Compose/pipeline.yml -p ${LOCAL_PIPELINE_NAME} --profile $PROFILE up -d
}

execute_run() {
    set -a

    podman-compose -f "Compose/simulator.yml" -p "${LOCAL_PIPELINE_NAME}_simulator" down

    LOCAL_PIPELINE_NAME=$1;shift;
    # Simulation 

    echo simulator running on $LOCAL_PIPELINE_NAME

    RUN_NAME=$1;shift;

    #
    # Set Local Variables
    #
    set_pipeline_local_variables $LOCAL_PIPELINE_NAME
    set_simulator_local_variables $RUN_NAME

    cat Compose/simulator.template.yml | envsubst > Compose/simulator.yml
    podman-compose -f "Compose/simulator.yml" -p "${LOCAL_PIPELINE_NAME}_simulator" up -d
    #echo simulator finished
}

#teardown_broker
teardown_pipeline test all

#deploy_broker
#sleep 5
deploy_pipeline test all

#sleep 3

execute_run test LetsDoARunBaby