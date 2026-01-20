####
# All shells in Executions/Run have the following global functions:
#   execution_run_init(EXECUTION_PIPELINE_SRC)

. ./Libs/lib.sh

set -a

### Called Globally and Locally.
execution_run_set_pipeline_name() {
    g_PIPELINE_NAME="TEST_011"
}

### Only Called Globally.
execution_run_init() {
    EXECUTION_PIPELINE_SRC=$1;shift;
    . ./../Pipeline/$EXECUTION_PIPELINE_SRC.sh

    set -a

    echo_subtitle "Executing Host Pipeline"
    execution_run_set_pipeline_name
    execution_pipeline_init

    sleep 3

    echo_subtitle "Executing Run"

    execution_pipeline_init_run 8 ShortTest "Benchmarks/timing.json"
    
    echo_subtitle "Run Execution Completed"
}