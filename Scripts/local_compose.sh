#export OTEL_BSP_MAX_QUEUE_SIZE=8192
set_pipeline_local_variables() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;

    #
    # Set Local Variables
    #
    PIPELINE_NAME=${g_PIPELINE_NAME}_${LOCAL_PIPELINE_NAME}
    
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
    NO_COLOR=${g_NO_COLOR}
    OTEL_LOG=${g_OTEL_LOG}
    
    OBSV_ADDRESS_EVENT_FORMATION=${g_OBSV_ADDRESS_EVENT_FORMATION}
    OBSV_ADDRESS_AGGREGATOR=${g_OBSV_ADDRESS_AGGREGATOR}
    OBSV_ADDRESS_WRITER=${g_OBSV_ADDRESS_WRITER}

    OTEL_ENDPOINT=${g_OTEL_ENDPOINT}
    
    OTEL_LEVEL_EVENT_FORMATION=${g_OTEL_LEVEL_EVENT_FORMATION}
    OTEL_LEVEL_AGGREGATOR=${g_OTEL_LEVEL_AGGREGATOR}
    OTEL_LEVEL_WRITER=${g_OTEL_LEVEL_WRITER}

    # Trace Source Dependent Event Formation Settings
    EF_POLARITY=${g_EF_POLARITY}
    EF_BASELINE=${g_EF_BASELINE}
    EF_INPUT_MODE=${g_EF_INPUT_MODE}
    EF_FTD_THRESHOLD=${g_EF_FTD_THRESHOLD}
    EF_FTD_DURATION=${g_EF_FTD_DURATION}
    EF_FTD_COOLOFF=${g_EF_FTD_COOLOFF}

    # Digitisers Expected from Broker
    DIGITISERS=${g_DIGITISERS}
    FRAME_TTL_MS=${g_FRAME_TTL_MS}

    # Output Path
    NEXUS_LOCAL_HOST_PATH=${g_NEXUS_LOCAL_HOST_PATH}_${LOCAL_PIPELINE_NAME}
    NEXUS_ARCHIVE_HOST_PATH=${g_NEXUS_ARCHIVE_HOST_PATH}_${LOCAL_PIPELINE_NAME}
    RUN_TTL_MS=${g_RUN_TTL_MS}
}

teardown_pipeline() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;
    PIPELINE_NAME=${g_PIPELINE_NAME}_${LOCAL_PIPELINE_NAME}

    podman-compose -f Compose/pipeline.yml -p ${PIPELINE_NAME} --profile main down
}

deploy_pipeline() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;

    echo deploying pipeline $LOCAL_PIPELINE_NAME

    set_pipeline_local_variables $LOCAL_PIPELINE_NAME
    
    mkdir $NEXUS_ARCHIVE_HOST_PATH $NEXUS_LOCAL_HOST_PATH
    touch $NEXUS_ARCHIVE_HOST_PATH/logs/nexus-writer.log $NEXUS_ARCHIVE_HOST_PATH/logs/digitiser-aggregator.log $NEXUS_ARCHIVE_HOST_PATH/logs/event-formation.log
    
    rpk topic create $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC

    cat Compose/pipeline.template.yml | envsubst > Compose/pipeline.yml
    podman-compose -f Compose/pipeline.yml --profile main -p ${PIPELINE_NAME} up -d
}

teardown_pipeline "1"

#sleep 1

#systemctl start --user podman.socket
deploy_pipeline "1"
