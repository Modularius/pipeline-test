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
./Scripts/local_compose.sh