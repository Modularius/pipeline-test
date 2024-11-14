## Include Library Scripts
. ./Libs/lib.sh

## Setup Pipeline
. ./Settings/PipelineSetup.sh

### Enact Pipeline Configuration for Chosen Broker
. ./Settings/Local/PipelineConfig.sh

do_pipeline_with_index_and_tte_mode() {
    INDEX=$1
    TTE_INPUT_MODE=$2

    rpk group delete trace-to-events_$INDEX digitiser-aggregator_$INDEX nexus-writer_$INDEX
    
    ARCHIVE_MOUNT=./archive/incoming/hifi_$INDEX
    LOCAL_MOUNT=./Output/Local_$INDEX

    FORMATION_PREFIX="sudo podman run --rm -d --memory 8g --restart on-failure --name=event_formation_$INDEX $IMAGE_PREFIX"
    AGGREGATOR_PREFIX="sudo podman run --rm -d --memory 2g --restart on-failure --name=digitiser_aggregator_$INDEX $IMAGE_PREFIX"
    NEXUS_WRITER_PREFIX="sudo podman run --rm -d --memory 8g --restart on-failure -v $ARCHIVE_MOUNT:/archive -v $LOCAL_MOUNT:/local --name=nexus_writer_$INDEX $IMAGE_PREFIX"

    TRACE_TO_EVENTS="${FORMATION_PREFIX}trace-to-events${APPLICATION_SUFFIX}"
    EVENT_AGGREGATOR="${AGGREGATOR_PREFIX}digitiser-aggregator${APPLICATION_SUFFIX}"
    NEXUS_WRITER="${NEXUS_WRITER_PREFIX}nexus-writer${APPLICATION_SUFFIX}"

    DAT_EVENT_TOPIC=daq-events_$INDEX
    FRAME_EVENT_TOPIC=frame-events_$INDEX
    
    GROUP_WRITER=nexus-writer_$INDEX
    GROUP_AGGREGATOR=digitiser-aggregator_$INDEX
    GROUP_EVENT_FORMATION=trace-to-events_$INDEX

    run_persistant_components
}

kill_persistant_components

# Run the followwing shell commands, subbing in for i
#mkdir Output/Local_i
#sudo mkdir archive/incoming/hifi_i
do_pipeline_with_index_and_tte_mode 0 "fixed-threshold-discriminator --threshold=2200 --duration=1 --cool-off=0"

do_pipeline_with_index_and_tte_mode 1 "fixed-threshold-discriminator --threshold=2300 --duration=1 --cool-off=0"