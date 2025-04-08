set -a
### Set Local Host
g_LOCALHOST=localhost

## Include Library Scripts
. ./Libs/lib.sh
. ./Libs/lib_pipeline.sh

## Setup Pipeline
. ./Settings/Pipeline.sh

### Enact Event Formation Configuration
. ./Settings/EventFormation.sh

### Enact Observability and Logging Configuration
. ./Settings/Observability.sh

### Enact Execution Configuration
. ./Settings/Execution.sh


### Enact Pipeline Configuration for Chosen Broker
#### Local
g_NUM_DIGITISERS=8
g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))
. ./Settings/Local/Broker.sh
#### HiFi
#. ./Settings/HiFi/Broker.sh
#### MuSR
#. ./Settings/MuSR/Broker.sh

echo "Current Time: $(date +"%T")"

## Main Script

#### Local
. ./Scripts/local_compose.sh
#. ./Scripts/local_no_docker.sh
#. ./Scripts/simulation.sh
#### HiFi
#. ./Scripts/hifi.sh