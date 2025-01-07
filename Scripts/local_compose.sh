
#export OTEL_BSP_MAX_QUEUE_SIZE=8192
teardown() {
    PIPELINE_NAME=$1;shift;

    teardown_containerised_pipeline $PIPELINE_NAME
    sleep 5
    teardown_pipeline_consumer_groups $PIPELINE_NAME
}

deploy() {
    LOCAL_PIPELINE_NAME=$1;shift;

    #
    # Set Local Variables
    #
    PIPELINE_NAME=${g_PIPELINE_NAME}${LOCAL_PIPELINE_NAME}
    
    # Broker Settings
    BROKER=g_BROKER
    GROUP_EVENT_FORMATION=g_GROUP_EVENT_FORMATION
    GROUP_AGGREGATOR=g_GROUP_AGGREGATOR
    GROUP_WRITER=g_GROUP_WRITER
   
    TRACE_TOPIC=g_TRACE_TOPIC
    DAT_EVENT_TOPIC=g_DAT_EVENT_TOPIC
    FRAME_EVENT_TOPIC=g_FRAME_EVENT_TOPIC
    CONTROL_TOPIC=g_CONTROL_TOPIC
    LOGS_TOPIC=g_LOGS_TOPIC
    SELOGS_TOPIC=g_SELOGS_TOPIC
    ALARMS_TOPIC=g_ALARMS_TOPIC

    # Observability
    RUST_LOG=g_RUST_LOG
    
    OBSV_ADDRESS_EVENT_FORMATION=g_OBSV_ADDRESS_EVENT_FORMATION
    OBSV_ADDRESS_AGGREGATOR=g_OBSV_ADDRESS_AGGREGATOR
    OBSV_ADDRESS_WRITER=g_OBSV_ADDRESS_WRITER

    OTEL_ENDPOINT=g_OTEL_ENDPOINT
    
    OTEL_LEVEL_EVENT_FORMATION=g_OTEL_LEVEL_EVENT_FORMATION
    OTEL_LEVEL_AGGREGATOR=g_OTEL_LEVEL_AGGREGATOR
    OTEL_LEVEL_WRITER=g_OTEL_LEVEL_WRITER
    OTEL_LEVEL_SIM=g_OTEL_LEVEL_SIM

    # Trace Source Dependent Event Formation Settings
    TTE_POLARITY=g_TTE_POLARITY
    TTE_BASELINE=g_TTE_BASELINE

    # Digitisers Expected from Broker
    DIGITIZERS=g_DIGITIZERS
    FRAME_TTL_MS=g_FRAME_TTL_MS

    # Output Path
    NEXUS_OUTPUT_PATH=g_NEXUS_OUTPUT_PATH
    NEXUS_ARCHIVE_PATH=g_NEXUS_ARCHIVE_PATH
    RUN_TTL_MS=g_RUN_TTL_MS

    # Simulation 
    SIMULATOR_PATH="Simulations"
    SIMULATOR_SOURCE="test.json"

    echo deploying pipeline $LOCAL_PIPELINE_NAME and running simulation

    cat Compose/docker-compose.yml | envsubst | docker compose -f - -p ${LOCAL_PIPELINE_NAME} up -d
}

execute_run() {
    PIPELINE_NAME=$1;shift;

    g_NUM_DIGITISERS=$1;shift;
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))

    g_RUN_NAME=$1;shift;
    export g_MAX_DIGITISER
    export g_NUM_DIGITISERS
    export g_RUN_NAME

    echo simulator start
    deploy_containerised_simulator $PIPELINE_NAME $g_SIMULATOR_CONFIG_SOURCE
    echo simulator finished

}


teardown pipeline1
teardown pipeline2
deploy pipeline1
deploy pipeline2
execute_run pipeline1 8 LetsDoARunBabe
teardown_containerised_simulator

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker up -d