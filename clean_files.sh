#!/bin/bash

set -a

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

### Set Pipeline Name
execution_run_set_pipeline_name

echo_title "Cleaning Files at $(date +"%T")"

##### Main Execution
execution_run_clean_files $1