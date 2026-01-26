#Fully Functional
#run_trace_simulator SIMULATOR BROKER CONTROL_TOPIC TRACE_TOPIC DAT_EVENT_TOPIC FRAME_EVENT_TOPIC OBSV_ADDRESS OTEL_ENDPOINT OTEL_LEVEL SIMULATOR_CONFIG_SOURCE
run_trace_simulator() {
    set -a
    
    SIMULATOR=$1;shift;
    BROKER=$1;shift;
    CONTROL_TOPIC=$1;shift;
    LOGS_TOPIC=$1;shift;
    SELOGS_TOPIC=$1;shift;
    ALARMS_TOPIC=$1;shift;
    TRACE_TOPIC=$1;shift;
    DAT_EVENT_TOPIC=$1;shift;
    FRAME_EVENT_TOPIC=$1;shift;

    OBSV_ADDRESS=$1;shift;
    OTEL_ENDPOINT=$1;shift;

    SIMULATOR_CONFIG_SOURCE=$1;shift;

    params=$(simulator_params)
    CMD="${SIMULATOR} $params"

    echo_heading_item "Executing Simulator" "$CMD"
    RUST_LOG=$g_RUST_LOG OTEL_LEVEL=$g_OTEL_LEVEL NO_COLOR=$g_NO_COLOR NUM_DIGITISERS=$g_NUM_DIGITISERS MAX_DIGITISER=$g_MAX_DIGITISER RUN_NAME=$g_RUN_NAME $CMD
}

simulator_params() {
    echo "--broker $BROKER \
    --otel-endpoint $OTEL_ENDPOINT \
    --otel-namespace=$g_PIPELINE_NAME \
    defined ${SIMULATOR_CONFIG_SOURCE} \
    --digitiser-trace-topic $TRACE_TOPIC \
    --digitiser-event-topic $DAT_EVENT_TOPIC \
    --frame-event-topic $FRAME_EVENT_TOPIC \
    --control-topic $CONTROL_TOPIC \
    --runlog-topic $LOGS_TOPIC \
    --selog-topic $SELOGS_TOPIC \
    --alarm-topic $ALARMS_TOPIC"
}

run_trace_reader() {
    BROKER="$1"
    FRAME_NUMBER=$2
    DID=$3
    OFFSET=$4
    NUM_TRACE_EVENTS=$5
    TRACE_TOPIC=$6

    $g_TRACE_READER \
        --broker $BROKER \
        --trace-topic $TRACE_TOPIC \
        --consumer-group trace-reader \
        --frame-number=$FRAME_NUMBER \
        --digitizer-id=$DID \
        $g_OTEL_ENDPOINT \
        --number-of-trace-events=$NUM_TRACE_EVENTS \
        --trace-offset=$OFFSET \
        --file-name "../Data/Traces/MuSR_A41_B42_C43_D44_Apr2021_Ag_ZF_IntDeg_Slit60_short.traces"
}