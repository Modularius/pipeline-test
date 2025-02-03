
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
    GROUP_EVENT_FORMATION=${g_GROUP_EVENT_FORMATION}
    GROUP_AGGREGATOR=${g_GROUP_AGGREGATOR}
    GROUP_WRITER=${g_GROUP_WRITER}
   
    TRACE_TOPIC=${g_TRACE_TOPIC}
    DAT_EVENT_TOPIC=${g_DAT_EVENT_TOPIC}
    FRAME_EVENT_TOPIC=${g_FRAME_EVENT_TOPIC}
    CONTROL_TOPIC=${g_CONTROL_TOPIC}
    LOGS_TOPIC=${g_LOGS_TOPIC}
    SELOGS_TOPIC=${g_SELOGS_TOPIC}
    ALARMS_TOPIC=${g_ALARMS_TOPIC}

    # Observability
    RUST_LOG=${g_RUST_LOG}
    
    OBSV_ADDRESS_EVENT_FORMATION=${g_OBSV_ADDRESS_EVENT_FORMATION}
    OBSV_ADDRESS_AGGREGATOR=${g_OBSV_ADDRESS_AGGREGATOR}
    OBSV_ADDRESS_WRITER=${g_OBSV_ADDRESS_WRITER}

    OTEL_ENDPOINT=${g_OTEL_ENDPOINT}
    
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

teardown_pipeline() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;

    docker compose -f Compose/pipeline.yml -p ${LOCAL_PIPELINE_NAME} down
}

deploy_pipeline() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;

    echo deploying pipeline $LOCAL_PIPELINE_NAME

    set_pipeline_local_variables $LOCAL_PIPELINE_NAME
    
    mkdir $NEXUS_ARCHIVE_PATH $NEXUS_OUTPUT_PATH
    
    cat Compose/pipeline.template.yml | envsubst > Compose/pipeline.yml
    docker compose -f Compose/pipeline.yml -p ${LOCAL_PIPELINE_NAME} up -d
}

execute_run() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;
    # Simulation 

    RUN_NAME=$1;shift;

    #
    # Set Local Variables
    #
    PIPELINE_NAME=${g_PIPELINE_NAME}${LOCAL_PIPELINE_NAME}

    BROKER=${g_BROKER}
    TRACE_TOPIC=${g_TRACE_TOPIC}
    DAT_EVENT_TOPIC=${g_DAT_EVENT_TOPIC}
    FRAME_EVENT_TOPIC=${g_FRAME_EVENT_TOPIC}
    CONTROL_TOPIC=${g_CONTROL_TOPIC}
    LOGS_TOPIC=${g_LOGS_TOPIC}
    SELOGS_TOPIC=${g_SELOGS_TOPIC}
    ALARMS_TOPIC=${g_ALARMS_TOPIC}
    
    RUST_LOG=${g_RUST_LOG}
    MAX_DIGITISER=${g_MAX_DIGITISER}
    NUM_DIGITISERS=${g_NUM_DIGITISERS}
    RUN_NAME=${RUN_NAME}

    OTEL_ENDPOINT=${g_OTEL_ENDPOINT}
    
    OTEL_LEVEL_SIM=${g_OTEL_LEVEL_SIM}
    OBSV_ADDRESS_SIM=${g_OBSV_ADDRESS_SIM}

    SIMULATOR_PATH="Simulations"
    SIMULATOR_SOURCE="test.json"

    echo simulator start
    cat Compose/simulator.template.yml | envsubst > Compose/simulator.yml
    docker compose -f "Compose/simulator.yml" -p "${LOCAL_PIPELINE_NAME}_simulator" up
    echo simulator finished

    docker compose -f "Compose/simulator.yml" -p "${LOCAL_PIPELINE_NAME}_simulator" down
}


teardown_pipeline pipeline
#deploy_pipeline pipeline
#execute_run pipeline LetsDoARunBabe

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker up -d