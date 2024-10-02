## Include Library Scripts
. ./Libs/lib.sh

## Setup Pipeline
. ./Settings/PipelineSetup.sh

### Enact Event Formation Configuration
. ./Settings/EventFormationConfig.sh

### Enact Pipeline Configuration for Chosen Broker
. ./Settings/Local/PipelineConfig.sh

RUN_NAME=DeadRun6865

echo "Starting Run"

send_run_start $RUN_NAME HiFi
sleep 10

echo "Ending Run"
send_run_stop $RUN_NAME HiFi