# Requires external env variable: `MY_PIPELINE_NAME`.
# This is appended to `g_PIPELINE_NAME` defined in `./Settings/Pipeline.sh`.

## Include Library Scripts
. ./Libs/lib.sh

## Setup Pipeline
. ./Settings/Pipeline.sh

### Enact Event Formation Configuration
. ./Settings/EventFormation.sh

### Enact Observability and Logging Configuration
. ./Settings/Observability.sh

### Enact Execution Configuration
. ./Settings/Execution.sh

### Enact Broker Configuration
. ./Settings/Local/Broker.sh

## Main Script

echo "Current Time: $(date +"%T")"

#./Scripts/multiple_pipelines.sh
. ./Scripts/deploy.sh
. ./Scripts/set_variables.sh

set_pipeline_local_variables "1"
reset_pipeline
deploy_pipeline "1"