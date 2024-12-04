. ./Libs/lib_components.sh

#g_CONTAINER_ENGINE="docker"
g_CONTAINER_ENGINE="podman"
g_IMAGE_PREFIX="ghcr.io/stfc-icd-research-and-design/supermusr"

#deploy_pipeline local inst1 8g 2g 8g "fixed-threshold-discriminator --threshold=2200 --duration=1 --cool-off=0" 
deploy_containerised_pipeline() {
    PIPELINE_NAME=$1;shift;
    EF_INDEX=$1;shift;
    DA_INDEX=$1;shift;
    NW_INDEX=$1;shift;
    EF_MEM=$1;shift;
    DA_MEM=$1;shift;
    NW_MEM=$1;shift;
    ARCHIVE_FOLDER_PREFIX=$1;shift;
    TTE_INPUT_MODE=$@

    echo "Deploying containerised pipeline with name $PIPELINE_NAME with properties:"
    echo "-" "EF_MEM = " $EF_MEM
    echo "-" "DA_MEM = " $DA_MEM
    echo "-" "NW_MEM = " $NW_MEM
    echo "-" "ARCHIVE_FOLDER = " $ARCHIVE_FOLDER
    echo "-" "TTE_INPUT_MODE = " $TTE_INPUT_MODE
    
    ### Container Commands

    TRACE_TO_EVENTS_COMMAND="sudo $g_CONTAINER_ENGINE run -d \
        --memory $EF_MEM \
        --network=host \
        --restart on-failure \
        --name=${PIPELINE_NAME}_event_formation \
        $g_IMAGE_PREFIX-trace-to-events:main"

    DIGITISER_AGGREGATOR_COMMAND="sudo $g_CONTAINER_ENGINE run -d \
        --memory $DA_MEM \
        --network=host \
        --restart on-failure \
        --name=${PIPELINE_NAME}_digitiser_aggregator \
        $g_IMAGE_PREFIX-digitiser-aggregator:main"

    ARCHIVE_MOUNT=./archive/incoming/${ARCHIVE_FOLDER_PREFIX}$PIPELINE_NAME
    LOCAL_MOUNT=./Output/${ARCHIVE_FOLDER_PREFIX}$PIPELINE_NAME

    NEXUS_WRITER_COMMAND="sudo $g_CONTAINER_ENGINE run -d \
        --memory $NW_MEM \
        --network=host \
        --restart on-failure \
        --name=${PIPELINE_NAME}_nexus_writer \
        -v $ARCHIVE_MOUNT:/archive -v $LOCAL_MOUNT:/local \
        $g_IMAGE_PREFIX-nexus-writer:main"

    DAT_EVENT_TOPIC=${PIPELINE_NAME}-${g_DAT_EVENT_TOPIC}
    FRAME_EVENT_TOPIC=${PIPELINE_NAME}-${g_FRAME_EVENT_TOPIC}

    rpk topic create $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC
    
    GROUP_WRITER=${PIPELINE_NAME}-nexus-writer
    GROUP_AGGREGATOR=${PIPELINE_NAME}-digitiser-aggregator
    GROUP_EVENT_FORMATION=${PIPELINE_NAME}-trace-to-events
    
    sudo mkdir $ARCHIVE_MOUNT --mode=666
    sudo mkdir $LOCAL_MOUNT --mode=666

    build_trace_to_events_command "$TRACE_TO_EVENTS_COMMAND" $EF_INDEX \
        $PIPELINE_NAME \
        localhost:9092 $GROUP_EVENT_FORMATION $g_TRACE_TOPIC $DAT_EVENT_TOPIC \
        $g_OBSV_ADDRESS "$g_OTEL_ENDPOINT" "$g_OTEL_LEVEL_EVENT_FORMATION" \
        $g_TTE_POLARITY $g_TTE_BASELINE $TTE_INPUT_MODE

    build_digitiser_aggregator_command "$DIGITISER_AGGREGATOR_COMMAND" $DA_INDEX \
        $PIPELINE_NAME \
        localhost:9092 $GROUP_AGGREGATOR $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC $g_FRAME_TTL_MS \
        $g_OBSV_ADDRESS "$g_OTEL_ENDPOINT" "$g_OTEL_LEVEL_AGGREGATOR" \
        $g_DIGITISERS

    build_nexus_writer_command "$NEXUS_WRITER_COMMAND" $NW_INDEX \
        $PIPELINE_NAME \
        localhost:9092 $GROUP_WRITER $g_CONTROL_TOPIC $FRAME_EVENT_TOPIC $g_RUN_TTL_MS \
        "local" "archive" \
        $g_OBSV_ADDRESS "$g_OTEL_ENDPOINT" "$g_OTEL_LEVEL_WRITER"
    
    echo "Pipeline Deployed"
    echo ""
}

teardown_pipeline_consumer_groups() {
    PIPELINE_NAME=$1;shift;
    
    GROUP_WRITER=${PIPELINE_NAME}-nexus-writer
    GROUP_AGGREGATOR=${PIPELINE_NAME}-digitiser-aggregator
    GROUP_EVENT_FORMATION=${PIPELINE_NAME}-trace-to-events
    
    echo "Tearing down consumer groups for pipeline: $PIPELINE_NAME" 
    rpk group delete $GROUP_WRITER $GROUP_AGGREGATOR $GROUP_EVENT_FORMATION
}

teardown_containerised_pipeline() {
    PIPELINE_NAME=$1;shift;

    echo "Tearing down pipeline: $PIPELINE_NAME"
    sudo $g_CONTAINER_ENGINE rm -f $($g_CONTAINER_ENGINE container ls --all --quiet --no-trunc --filter "name=${PIPELINE_NAME}_event_formation")
    sudo $g_CONTAINER_ENGINE rm -f $($g_CONTAINER_ENGINE container ls --all --quiet --no-trunc --filter "name=${PIPELINE_NAME}_digitiser_aggregator")
    sudo $g_CONTAINER_ENGINE rm -f $($g_CONTAINER_ENGINE container ls --all --quiet --no-trunc --filter "name=${PIPELINE_NAME}_nexus_writer")
}

teardown_containerised_simulator() {
    echo "Tearing down simulator"
    sudo $g_CONTAINER_ENGINE rm -f $($g_CONTAINER_ENGINE container ls --all --quiet --no-trunc --filter "name=simulator")
}

deploy_containerised_simulator() {
    PIPELINE_NAME=$1;shift;
    SIMULATOR_CONFIG_SOURCE=$@
    
    SIMULATOR_COMMAND="$g_CONTAINER_ENGINE run \
        -v ./Simulations:/Simulations \
        --network=host \
        -e g_RUN_NAME=$g_RUN_NAME -e g_NUM_DIGITISERS=$g_NUM_DIGITISERS -e g_MAX_DIGITISER=$g_MAX_DIGITISER \
        --name=simulator \
        $g_IMAGE_PREFIX-simulator:main"
        
    DAT_EVENT_TOPIC=${PIPELINE_NAME}-${g_DAT_EVENT_TOPIC}
    FRAME_EVENT_TOPIC=${PIPELINE_NAME}-${g_FRAME_EVENT_TOPIC}

    run_trace_simulator "$SIMULATOR_COMMAND" \
        $g_BROKER $g_CONTROL_TOPIC $g_TRACE_TOPIC $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC \
        $g_OBSV_ADDRESS "$g_OTEL_ENDPOINT" "$g_OTEL_LEVEL_SIM" \
        $SIMULATOR_CONFIG_SOURCE
}