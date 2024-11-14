run_trace_simulator() {
    $g_SIMULATOR \
        --broker $g_BROKER \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL_SIM \
        defined "$g_SIMULATOR_CONFIG_SOURCE" \
        --digitiser-trace-topic $g_TRACE_TOPIC \
        --digitiser-event-topic $g_DAT_EVENT_TOPIC \
        --frame-event-topic $g_FRAME_EVENT_TOPIC \
        --control-topic $g_CONTROL_TOPIC \
        --runlog-topic $g_CONTROL_TOPIC \
        --selog-topic $g_CONTROL_TOPIC \
        --alarm-topic $g_CONTROL_TOPIC
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