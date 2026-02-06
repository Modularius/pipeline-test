./Libs/lib.sh
./Libs/lib_components.sh

$CONTAINER_ENGINE="podman"

#deploy_pipeline inst1 8g 2g 8g True "fixed-threshold-discriminator --threshold=2200 --duration=1 --cool-off=0"
deploy_pipeline() {
    PIPELINE_NAME=$1;shift;
    EF_MEM=$1;shift;
    DA_MEM=$1;shift;
    NW_MEM=$1;shift;
    REMOVE_GROUPS=$1;shift;
    TTE_INPUT_MODE=$@
    
    ### Container Commands
    FORMATION_PREFIX="sudo $CONTAINER_ENGINE run --rm -d --memory $EF_MEM --restart on-failure --name=event_formation_$PIPELINE_NAME \
        $IMAGE_PREFIX-trace-to-events:main"

    AGGREGATOR_PREFIX="sudo $CONTAINER_ENGINE run --rm -d --memory $DA_MEM --restart on-failure --name=digitiser_aggregator_$PIPELINE_NAME \
        $IMAGE_PREFIX-digitiser-aggregator:main"

    ARCHIVE_MOUNT=./archive/incoming/hifi_$PIPELINE_NAME
    LOCAL_MOUNT=./Output/Local_$PIPELINE_NAME

    NEXUS_WRITER_PREFIX="sudo $CONTAINER_ENGINE run --rm -d --memory $NW_MEM --restart on-failure --name=nexus_writer_$PIPELINE_NAME \
        -v $ARCHIVE_MOUNT:/archive -v $LOCAL_MOUNT:/local \
        $IMAGE_PREFIX-nexus-writer:main"

    DAT_EVENT_TOPIC=daq-events-$PIPELINE_NAME
    FRAME_EVENT_TOPIC=frame-events-$PIPELINE_NAME

    rpk topic create $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC
    
    GROUP_WRITER=nexus-writer-$PIPELINE_NAME
    GROUP_AGGREGATOR=digitiser-aggregator-$PIPELINE_NAME
    GROUP_EVENT_FORMATION=trace-to-events-$PIPELINE_NAME
    
    if [ "$REMOVE_GROUPS" = true ] ; then
        rpk group delete $GROUP_WRITER $GROUP_AGGREGATOR $GROUP_EVENT_FORMATION
    fi

    build_trace_to_events_command $TRACE_TO_EVENTS \
        $g_BROKER $GROUP_EVENT_FORMATION $g_TRACE_TOPIC $DAT_EVENT_TOPIC \
        $g_OBSV_ADDRESS $g_OTEL_ENDPOINT $g_OTEL_LEVEL_EVENT_FORMATION \
        $g_TTE_POLARITY $g_TTE_BASELINE $TTE_INPUT_MODE

    build_digitiser_aggregator_command $TRACE_TO_EVENTS \
        $g_BROKER $GROUP_AGGREGATOR $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC $g_FRAME_TTL_MS \
        $g_OBSV_ADDRESS $g_OTEL_ENDPOINT $g_OTEL_LEVEL_EVENT_FORMATION \
        $g_DIGITISERS

    build_nexus_writer_command $TRACE_TO_EVENTS \
        $g_BROKER $GROUP_WRITER $FRAME_EVENT_TOPIC $g_CONTROL_TOPIC $g_RUN_TTL_MS \
        $g_NEXUS_OUTPUT_PATH $g_NEXUS_ARCHIVE_PATH \
        $g_OBSV_ADDRESS $g_OTEL_ENDPOINT $g_OTEL_LEVEL_EVENT_FORMATION \
        $g_TTE_POLARITY $g_TTE_BASELINE $TTE_INPUT_MODE
}