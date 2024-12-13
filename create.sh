## Include Library Scripts
. ./Libs/build_commands/lib.sh

## Setup Pipeline
. ./Settings/PipelineSetup.sh

### Enact Event Formation Configuration
. ./Settings/EventFormationConfig.sh

### Enact Pipeline Configuration for Chosen Broker
. ./Settings/Local/PipelineConfig.sh


mkdir ${NEXUS_ARCHIVE_MOUNT} --mode=775
mkdir ${NEXUS_LOCAL_MOUNT} --mode=775

rpk topic create $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC


EF_PODMAN_PARAMETERS=build_common_podman_parameters 4g on-failure 100m $RUST_LOG "trace-to-events"

EF_PODMAN_COMMANDS=
build_podman_command "container create" $IMAGE_PREFIX "trace-to-events" "main"