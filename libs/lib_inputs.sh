#SIMULATOR="cargo run --release --bin simulator --"
#TRACE_READER="cargo run --release --bin trace-reader --"

SIMULATOR="../supermusr-data-pipeline/target/release/simulator"
TRACE_READER="../supermusr-data-pipeline/target/release/trace-reader"

run_trace_simulator() {
    $SIMULATOR \
        --broker $BROKER \
        --trace-topic $TRACE_TOPIC \
        --event-topic $DAT_EVENT_TOPIC \
        --frame-event-topic $FRAME_EVENT_TOPIC \
        --control-topic $CONTROL_TOPIC \
        --otel-endpoint $OTEL_ENDPOINT \
        $OTEL_LEVEL \
        defined "$SIMULATOR_CONFIG_SOURCE" \
        --runlog-topic $CONTROL_TOPIC \
        --selog-topic $CONTROL_TOPIC \
        --alarm-topic $CONTROL_TOPIC
}

run_trace_reader() {
    BROKER="$1"
    FRAME_NUMBER=$2
    DID=$3
    OFFSET=$4
    NUM_TRACE_EVENTS=$5
    TRACE_TOPIC=$6

    $TRACE_READER \
        --broker $BROKER \
        --trace-topic $TRACE_TOPIC \
        --consumer-group trace-reader \
        --frame-number=$FRAME_NUMBER \
        --digitizer-id=$DID \
        --otel-endpoint $OTEL_ENDPOINT \
        --number-of-trace-events=$NUM_TRACE_EVENTS \
        --trace-offset=$OFFSET \
        --file-name "../Data/Traces/MuSR_A41_B42_C43_D44_Apr2021_Ag_ZF_IntDeg_Slit60_short.traces"
}
