## Include Library Scripts
. ./Libs/lib.sh

## Setup Pipeline
. ./Settings/PipelineSetup.sh

### Enact Pipeline Configuration for Chosen Broker
. ./Settings/Local/PipelineConfig.sh


teardown_pipeline_with_index() {
    INDEX=$1; shift;

    NAME_WRITER=nexus_writer_$INDEX
    NAME_AGGREGATOR=digitiser_aggregator_$INDEX
    NAME_EVENT_FORMATION=event_formation_$INDEX

    PID_WRITER=$(sudo podman container ls --all --quiet --no-trunc --filter "name=${NAME_WRITER}")
    PID_AGGREGATOR=$(sudo podman container ls --all --quiet --no-trunc --filter "name=${NAME_AGGREGATOR}")
    PID_EVENT_FORMATION=$(sudo podman container ls --all --quiet --no-trunc --filter "name=${NAME_EVENT_FORMATION}")

    sudo podman rm -f $PID_WRITER $PID_AGGREGATOR $PID_EVENT_FORMATION
}

teardown_pipeline_consumer_groups_with_index() {
    INDEX=$1; shift;
    
    GROUP_WRITER=nexus-writer_$INDEX
    GROUP_AGGREGATOR=digitiser-aggregator_$INDEX
    GROUP_EVENT_FORMATION=trace-to-events_$INDEX

    rpk group delete $GROUP_EVENT_FORMATION $GROUP_AGGREGATOR $GROUP_WRITER
}


do_pipeline_with_index_and_event_formation_settings() {
    INDEX=$1; shift;
    THRESHOLD=$1; shift;
    DURATION=$1; shift;
    COOL_OFF=$1; shift;
    do_pipeline_with_index_and_tte_mode $INDEX "fixed-threshold-discriminator --threshold=$THRESHOLD --duration=$DURATION --cool-off=$COOL_OFF"
}

do_pipeline_with_index_and_tte_mode() {
    INDEX=$1
    TTE_INPUT_MODE=$2
    
    ARCHIVE_MOUNT=./archive/incoming/hifi_$INDEX
    LOCAL_MOUNT=./Output/Local_$INDEX

    mkdir Output/Local_$INDEX --mode=666
    sudo mkdir archive/incoming/hifi_$INDEX --mode=666

    rpk topic create $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC
    
    FORMATION_MEM=2g
    FORMATION_PREFIX="sudo podman run --rm -d \
        --memory ${FORMATION_MEM} \
        --restart on-failure \
        --log-opt max-size=100m \
        --env RUST_LOG=$RUST_LOG \
        --name=event_formation_$INDEX $IMAGE_PREFIX"

    AGGREGATOR_MEM=4g
    AGGREGATOR_PREFIX="sudo podman run --rm -d \
        --memory ${AGGREGATOR_MEM} \
        --restart on-failure \
        --log-opt max-size=100m \
        --env RUST_LOG=$RUST_LOG \
        --publish=29090:2909 \
        --name=digitiser_aggregator_$INDEX $IMAGE_PREFIX"

    NEXUS_WRITER_MEM=4g
    NEXUS_WRITER_PREFIX="sudo podman run --rm -d \
        --memory ${NEXUS_WRITER_MEM} --restart on-failure \
        --log-opt max-size=100m \
        --env RUST_LOG=$RUST_LOG -v \
        $ARCHIVE_MOUNT:/archive -v $LOCAL_MOUNT:/local \
        --name=nexus_writer_$INDEX $IMAGE_PREFIX"

    #TRACE_TO_EVENTS="${FORMATION_PREFIX}trace-to-events${APPLICATION_SUFFIX}"
    TRACE_TO_EVENTS="../supermusr-data-pipeline/target/release/trace-to-events"
    EVENT_AGGREGATOR="${AGGREGATOR_PREFIX}digitiser-aggregator${APPLICATION_SUFFIX}"
    NEXUS_WRITER="${NEXUS_WRITER_PREFIX}nexus-writer${APPLICATION_SUFFIX}"

    DAT_EVENT_TOPIC=daq-events_$INDEX
    FRAME_EVENT_TOPIC=frame-events_$INDEX
    
    GROUP_WRITER=nexus-writer_$INDEX
    GROUP_AGGREGATOR=digitiser-aggregator_$INDEX
    GROUP_EVENT_FORMATION=trace-to-events_$INDEX

    EF_CONFIGURATION_OPTIONS="cli-options: ${TTE_INPUT_MODE}, memory: ${FORMATION_MEM}"
    DA_CONFIGURATION_OPTIONS="digitisers: \"${DIGITISERS}\", frame_ttl_ms: ${FRAME_TTL_MS}, frame_buffer_size: ${FRAME_BUFFER_SIZE}, memory: ${AGGREGATOR_MEM}"
    NW_CONFIGURATION_OPTIONS="run_ttl_ms: ${RUN_TTL_MS}, memory: ${NEXUS_WRITER_MEM}"
    CONFIGURATION_OPTIONS="event-formation-config:{${EF_CONFIGURATION_OPTIONS}}, digitiser-aggregator-config: {${DA_CONFIGURATION_OPTIONS}}, nexus-writer-config: {${NW_CONFIGURATION_OPTIONS}}" 
    
    PIPELINE_NAME="pipeline_$INDEX"

    run_persistant_components
}

#teardown_pipeline_with_index 0
#teardown_pipeline_with_index 1
#teardown_pipeline_with_index 2
#teardown_pipeline_with_index 3

sleep 5

#teardown_pipeline_consumer_groups_with_index 0
#teardown_pipeline_consumer_groups_with_index 1
#teardown_pipeline_consumer_groups_with_index 2
#teardown_pipeline_consumer_groups_with_index 3

sleep 2

#do_pipeline_with_index_and_event_formation_settings 0 2075 1 0
do_pipeline_with_index_and_event_formation_settings 1 2100 1 0
#do_pipeline_with_index_and_event_formation_settings 2 2200 1 0
#do_pipeline_with_index_and_event_formation_settings 3 2300 1 0