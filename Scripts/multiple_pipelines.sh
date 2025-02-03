## Include Library Scripts
. ./Libs/lib.sh

## Setup Pipeline
. ./Settings/Pipeline.sh

### Enact Pipeline Configuration for Chosen Broker
. ./Settings/Local/Broker.sh


teardown_pipeline_with_index() {
    INDEX=$1; shift;

    NAME_WRITER=nexus_writer_$INDEX
    NAME_AGGREGATOR=digitiser_aggregator_$INDEX
    NAME_EVENT_FORMATION=event_formation_$INDEX

    PID_WRITER=$(podman container ls --all --quiet --no-trunc --filter "name=${NAME_WRITER}")
    PID_AGGREGATOR=$(podman container ls --all --quiet --no-trunc --filter "name=${NAME_AGGREGATOR}")
    PID_EVENT_FORMATION=$(podman container ls --all --quiet --no-trunc --filter "name=${NAME_EVENT_FORMATION}")

    podman rm -f $PID_WRITER $PID_AGGREGATOR $PID_EVENT_FORMATION
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
    IMAGE_LOCATION=$1; shift;
    IMAGE_TAG=$1; shift;
    MAX_EVENTS_TO_CACHE=$1; shift;
    do_pipeline_with_index_and_tte_mode $INDEX "fixed-threshold-discriminator --threshold=$THRESHOLD --duration=$DURATION --cool-off=$COOL_OFF" $IMAGE_LOCATION $IMAGE_TAG $MAX_EVENTS_TO_CACHE
}

set_pipeline_local_variables() {
    set -a

    LOCAL_PIPELINE_NAME=$1;shift;

    #
    # Set Local Variables
    #
    PIPELINE_NAME=${g_PIPELINE_NAME}_${LOCAL_PIPELINE_NAME}
    
    # Broker Settings
    BROKER=${g_BROKER}
    GROUP_WRITER=${g_GROUP_WRITER}_$LOCAL_PIPELINE_NAME
    GROUP_AGGREGATOR=${g_GROUP_AGGREGATOR}_$LOCAL_PIPELINE_NAME
    GROUP_EVENT_FORMATION=${g_GROUP_EVENT_FORMATION}_$LOCAL_PIPELINE_NAME
   
    TRACE_TOPIC=${g_TRACE_TOPIC}
    DAT_EVENT_TOPIC=${g_DAT_EVENT_TOPIC}_$LOCAL_PIPELINE_NAME
    FRAME_EVENT_TOPIC=${FRAME_EVENT_TOPIC}_$LOCAL_PIPELINE_NAME
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
    EF_POLARITY=${g_EF_POLARITY}
    EF_BASELINE=${g_EF_BASELINE}
    EF_INPUT_MODE=${g_EF_INPUT_MODE}
    EF_FTD_THRESHOLD=${g_EF_FTD_THRESHOLD}
    EF_FTD_DURATION=${g_EF_FTD_DURATION}
    EF_FTD_COOLOFF=${g_EF_FTD_COOLOFF}
    EF_INPUT_COMMAND="fixed-threshold-discriminator --threshold ${EF_FTD_THRESHOLD} --duration ${EF_FTD_DURATION} --cool-off ${EF_FTD_COOLOFF}"

    # Digitisers Expected from Broker
    DIGITISERS=${g_DIGITISERS}
    FRAME_TTL_MS=${g_FRAME_TTL_MS}
    FRAME_BUFFER_SIZE=4000

    # Output Path
    NEXUS_LOCAL_HOST_PATH=./Output/Local_1
    NEXUS_ARCHIVE_HOST_PATH=./archive/incoming/hifi_1
    RUN_TTL_MS=${g_RUN_TTL_MS}
}


do_pipeline_with_index_and_tte_mode() {
    INDEX=$1; shift;
    EF_INPUT_MODE=$1; shift;
    IMAGE_LOCATION=$1; shift;
    IMAGE_TAG=$1; shift;
    MAX_EVENTS_TO_CACHE=$1; shift;
    
    set_pipeline_local_variables $INDEX

    LOCAL_MOUNT=local
    ARCHIVE_MOUNT=archive

    mkdir Output/Local_$INDEX --mode=775
    mkdir archive/incoming/hifi_$INDEX --mode=775

    #rpk topic create $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC
    
    FORMATION_MEM=2g
    FORMATION_PREFIX="podman run --rm -d \
        --memory ${FORMATION_MEM} \
        --restart on-failure \
        --log-opt max-size=100m \
        -v ./logs/event-formation:/home/logs
        --env RUST_LOG=$RUST_LOG \
        --name=event_formation_$INDEX ${IMAGE_LOCATION}${IMAGE_PREFIX}"

    AGGREGATOR_MEM=4g
    AGGREGATOR_PREFIX="podman run --rm -d \
        --memory ${AGGREGATOR_MEM} \
        --restart on-failure \
        --log-opt max-size=100m \
        --env RUST_LOG=$RUST_LOG \
        -v ./logs/digitiser-aggregator:/home/logs \
        --name=digitiser_aggregator_$INDEX ${IMAGE_LOCATION}${IMAGE_PREFIX}"

#        --oom-score-adj -1000 \
    NEXUS_WRITER_MEM=12g
    NEXUS_WRITER_PREFIX="podman run --rm -d \
        --memory ${NEXUS_WRITER_MEM} \
        --restart on-failure \
        --log-opt max-size=100m \
        --env RUST_LOG=$RUST_LOG \
        -v ./logs/nexus-writer-test:/home/logs \
        -v $NEXUS_ARCHIVE_PATH:/$ARCHIVE_MOUNT -v $NEXUS_LOCAL_PATH:/$LOCAL_MOUNT \
        --name=nexus_writer_$INDEX ${IMAGE_LOCATION}${IMAGE_PREFIX}"

    TRACE_TO_EVENTS="${FORMATION_PREFIX}trace-to-events:${IMAGE_TAG}"
    EVENT_AGGREGATOR="${AGGREGATOR_PREFIX}digitiser-aggregator:${IMAGE_TAG}"
    NEXUS_WRITER="${NEXUS_WRITER_PREFIX}nexus-writer:${IMAGE_TAG}"

    EF_CONFIGURATION_OPTIONS="cli-options: ${EF_INPUT_MODE}, memory: ${FORMATION_MEM}"
    DA_CONFIGURATION_OPTIONS="digitisers: \"${DIGITIZERS}\", frame_ttl_ms: ${FRAME_TTL_MS}, frame_buffer_size: ${FRAME_BUFFER_SIZE}, memory: ${AGGREGATOR_MEM}"
    NW_CONFIGURATION_OPTIONS="run_ttl_ms: ${RUN_TTL_MS}, memory: ${NEXUS_WRITER_MEM}"
    CONFIGURATION_OPTIONS="event-formation-config:{${EF_CONFIGURATION_OPTIONS}}, digitiser-aggregator-config: {${DA_CONFIGURATION_OPTIONS}}, nexus-writer-config: {${NW_CONFIGURATION_OPTIONS}}" 
    
    PIPELINE_NAME="pipeline_$INDEX"

    run_persistant_components
}

#teardown_pipeline_with_index 0
#teardown_pipeline_with_index 1
#teardown_pipeline_with_index 2
#teardown_pipeline_with_index 3

#sleep 5

#teardown_pipeline_consumer_groups_with_index 0
#teardown_pipeline_consumer_groups_with_index 1
#teardown_pipeline_consumer_groups_with_index 2
#teardown_pipeline_consumer_groups_with_index 3

#sleep 2

EXTERNAL="ghcr.io/stfc-icd-research-and-design/supermusr-"

#do_pipeline_with_index_and_event_formation_settings 0 2075 1 0 $EXTERNAL "main"
do_pipeline_with_index_and_event_formation_settings "1" 2100 1 0 $EXTERNAL "main" ""
#do_pipeline_with_index_and_event_formation_settings "test1" 2100 1 0 "localhost" "latest" ""
#do_pipeline_with_index_and_event_formation_settings "test2" 2100 1 0 "localhost" "latest" "--max-events-to-cache=1048576"
#do_pipeline_with_index_and_event_formation_settings 2 2200 1 0 $EXTERNAL "main"
#do_pipeline_with_index_and_event_formation_settings 3 2300 1 0 $EXTERNAL "main"