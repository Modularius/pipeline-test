set -a

## Include Library Scripts
source ./Libs/lib.sh
source ./Libs/lib_pipeline.sh

## Setup Pipeline
source ./Settings/Pipeline.sh

### Enact Event Formation Configuration
source ./Settings/EventFormation.sh

### Enact Observability and Logging Configuration
source ./Settings/Observability.sh

### Enact Execution Configuration
source ./Settings/Execution.sh


### Enact Pipeline Configuration for Chosen Broker
#### Local
g_MAX_DIGITISER=7
source ./Settings/Local/Broker.sh
#### HiFi
#source ./Settings/HiFi/Broker.sh

echo "Current Time: $(date +"%T")"

## Main Script

#### Local
source ./Scripts/local_containerised.sh
#### HiFi
#source ./Scripts/hifi.sh