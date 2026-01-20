#!/bin/bash

set -aeuo pipefail
IFS=$'\n\t'

###### Load Execution Functions
. ./Executions/Pipeline/$1.sh
. ./Executions/Run/$2.sh

execution_pipeline_init_environment

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

### Enact Pipeline Configuration for Chosen Broker
execution_pipeline_init_broker_settings

echo_title "Running Pipeline at: $(date +"%T")"

##### Main Execution
execution_run_init $1