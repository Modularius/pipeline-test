#Fully Functional
#run_trace_simulator SIMULATOR BROKER CONTROL_TOPIC TRACE_TOPIC DAT_EVENT_TOPIC FRAME_EVENT_TOPIC OBSV_ADDRESS OTEL_ENDPOINT OTEL_LEVEL SIMULATOR_CONFIG_SOURCE
run_trace_simulator() {
    SIMULATOR=$1;shift;
    BROKER=$1;shift;
    CONTROL_TOPIC=$1;shift;
    TRACE_TOPIC=$1;shift;
    DAT_EVENT_TOPIC=$1;shift;
    FRAME_EVENT_TOPIC=$1;shift;

    OBSV_ADDRESS=$1;shift;
    OTEL_ENDPOINT=$1;shift;
    OTEL_LEVEL=$1;shift;

    SIMULATOR_CONFIG_SOURCE=$1;shift;

    echo "--" "Executing Nexus Writer with properties:"
    echo "--" "-" "$SIMULATOR"
    echo "--" "-" "--broker $BROKER"
    echo "--" "-" "$OTEL_ENDPOINT"
    echo "--" "-" "$OTEL_LEVEL"
    echo "--" "-" "defined "$SIMULATOR_CONFIG_SOURCE""
    echo "--" "-" "--digitiser-trace-topic $TRACE_TOPIC"
    echo "--" "-" "--digitiser-event-topic $DAT_EVENT_TOPIC"
    echo "--" "-" "--frame-event-topic $FRAME_EVENT_TOPIC"
    echo "--" "-" "--control-topic $CONTROL_TOPIC"
    echo "--" "-" "--runlog-topic $CONTROL_TOPIC"
    echo "--" "-" "--selog-topic $CONTROL_TOPIC"
    echo "--" "-" "--alarm-topic $CONTROL_TOPIC"

    CMD="${SIMULATOR} \
        --broker $BROKER \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL \
        defined ${SIMULATOR_CONFIG_SOURCE} \
        --digitiser-trace-topic $TRACE_TOPIC \
        --digitiser-event-topic $DAT_EVENT_TOPIC \
        --frame-event-topic $FRAME_EVENT_TOPIC \
        --control-topic $CONTROL_TOPIC \
        --runlog-topic $CONTROL_TOPIC \
        --selog-topic $CONTROL_TOPIC \
        --alarm-topic $CONTROL_TOPIC"

    echo $CMD
    RUST_LOG=$g_RUST_LOG $CMD
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