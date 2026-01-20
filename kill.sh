#!/bin/bash

set -a

###### Load Execution Functions
. ./Executions/Pipeline/$1.sh

## Include Library Scripts
. ./Libs/lib.sh

### Enact Execution Configuration
. ./Settings/Execution.sh

echo_title "Killing Pipeline at: $(date +"%T")"

##### Main Execution
execution_pipeline_init_environment
execution_pipeline_kill