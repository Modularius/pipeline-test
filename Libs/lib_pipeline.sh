. ./Libs/lib_components.sh

g_CONTAINER_ENGINE="docker"
#g_CONTAINER_ENGINE="podman"
g_IMAGE_PREFIX="ghcr.io/stfc-icd-research-and-design/supermusr"

#deploy_pipeline inst1 8g 2g 8g "fixed-threshold-discriminator --threshold=2200 --duration=1 --cool-off=0" 
deploy_containerised_pipeline() {
    PIPELINE_NAME=$1;shift;
    EF_MEM=$1;shift;
    DA_MEM=$1;shift;
    NW_MEM=$1;shift;
    TTE_INPUT_MODE=$@

    echo "Deploying containerised pipeline with name $PIPELINE_NAME with properties:"
    echo "-" "EF_MEM = " $EF_MEM
    echo "-" "DA_MEM = " $DA_MEM
    echo "-" "NW_MEM = " $NW_MEM
    echo "-" "REMOVE_GROUPS = " $REMOVE_GROUPS
    echo "-" "TTE_INPUT_MODE = " $TTE_INPUT_MODE
    
    ### Container Commands

    TRACE_TO_EVENTS_COMMAND="sudo $g_CONTAINER_ENGINE run -d --memory $EF_MEM --restart on-failure --name=${PIPELINE_NAME}_event_formation \
        $g_IMAGE_PREFIX-trace-to-events:main"

    DIGITISER_AGGREGATOR_COMMAND="sudo $g_CONTAINER_ENGINE run -d --memory $DA_MEM --restart on-failure --name=${PIPELINE_NAME}_digitiser_aggregator \
        $g_IMAGE_PREFIX-digitiser-aggregator:main"

    ARCHIVE_MOUNT=./archive/incoming/hifi_$PIPELINE_NAME
    LOCAL_MOUNT=./Output/Local_$PIPELINE_NAME

    NEXUS_WRITER_COMMAND="sudo $g_CONTAINER_ENGINE run -d --memory $NW_MEM --restart on-failure --name=${PIPELINE_NAME}_nexus_writer \
        -v $ARCHIVE_MOUNT:/archive -v $LOCAL_MOUNT:/local \
        $g_IMAGE_PREFIX-nexus-writer:main"

    DAT_EVENT_TOPIC=${PIPELINE_NAME}-daq-events
    FRAME_EVENT_TOPIC=${PIPELINE_NAME}-frame-events

    rpk topic create $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC
    
    GROUP_WRITER=${PIPELINE_NAME}-nexus-writer
    GROUP_AGGREGATOR=${PIPELINE_NAME}-digitiser-aggregator
    GROUP_EVENT_FORMATION=${PIPELINE_NAME}-trace-to-events
    
    build_trace_to_events_command "$TRACE_TO_EVENTS_COMMAND" \
        $g_BROKER $GROUP_EVENT_FORMATION $g_TRACE_TOPIC $DAT_EVENT_TOPIC \
        $g_OBSV_ADDRESS "$g_OTEL_ENDPOINT" "$g_OTEL_LEVEL_EVENT_FORMATION" \
        $g_TTE_POLARITY $g_TTE_BASELINE "$TTE_INPUT_MODE"

    build_digitiser_aggregator_command "$DIGITISER_AGGREGATOR_COMMAND" \
        $g_BROKER $GROUP_AGGREGATOR $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC $g_FRAME_TTL_MS \
        $g_OBSV_ADDRESS "$g_OTEL_ENDPOINT" "$g_OTEL_LEVEL_AGGREGATOR" \
        $g_DIGITISERS

    build_nexus_writer_command "$NEXUS_WRITER_COMMAND" \
        $g_BROKER $GROUP_WRITER $FRAME_EVENT_TOPIC $g_CONTROL_TOPIC $g_RUN_TTL_MS \
        $g_NEXUS_OUTPUT_PATH $g_NEXUS_ARCHIVE_PATH \
        $g_OBSV_ADDRESS "$g_OTEL_ENDPOINT" "$g_OTEL_LEVEL_WRITER"
        
    echo "Pipeline Deployed"
    echo ""
}

teardown_pipeline_consumer_groups() {
    PIPELINE_NAME=$1;shift;
    
    GROUP_WRITER=${PIPELINE_NAME}-nexus-writer
    GROUP_AGGREGATOR=${PIPELINE_NAME}-digitiser-aggregator
    GROUP_EVENT_FORMATION=${PIPELINE_NAME}-trace-to-events
    
    rpk group delete $GROUP_WRITER $GROUP_AGGREGATOR $GROUP_EVENT_FORMATION
}

teardown_containerised_pipeline() {
    PIPELINE_NAME=$1;shift;

    sudo g_CONTAINER_ENGINE kill $(g_CONTAINER_ENGINE container ls --all --quiet --no-trunc --filter "name=${PIPELINE_NAME}_event_formation")
    sudo g_CONTAINER_ENGINE kill $(g_CONTAINER_ENGINE container ls --all --quiet --no-trunc --filter "name=${PIPELINE_NAME}_digitiser_aggregator")
    sudo g_CONTAINER_ENGINE kill $(g_CONTAINER_ENGINE container ls --all --quiet --no-trunc --filter "name=${PIPELINE_NAME}_nexus_writer")
}