#TRACE_TO_EVENTS="cargo run --release --bin trace-to-events --"
#SIMULATOR="cargo run --release --bin simulator --"
#TRACE_READER="cargo run --release --bin trace-reader --"
#NEXUS_WRITER="cargo run --release --bin nexus-writer --"
#EVENT_AGGREGATOR="cargo run --release --bin digitiser-aggregator --"

TRACE_TO_EVENTS="target/release/trace-to-events"
SIMULATOR="target/release/simulator"
TRACE_READER="target/release/trace-reader"
NEXUS_WRITER="target/release/nexus-writer"
EVENT_AGGREGATOR="target/release/digitiser-aggregator"

OTEL_ENDPOINT="http://localhost:4317/v1/traces"
#--save-file output/Saves/Tests/output_ \

run_trace_to_events() {
    BROKER="$1"
    INPUT="$2"
    TTE_INPUT_MODE="$3"
    TRACE_TOPIC="$4"
    EVENTS_TOPIC="$5"
    GROUP="$6"
    OBS_ADDRESS="$7"

    echo $TTE_INPUT_MODE

    [ $INPUT = simulator ] \
    && TRACE_TO_EVENTS_INPUT_MODE="--polarity positive --baseline=0" \
    || TRACE_TO_EVENTS_INPUT_MODE="--polarity negative --baseline=100"
    TRACE_TO_EVENTS_INPUT_MODE="--polarity positive --baseline=0"

    echo "--" "--" "Executing Event Formation"
    $TRACE_TO_EVENTS \
        --broker $BROKER --group $GROUP \
        --trace-topic $TRACE_TOPIC \
        --event-topic $EVENTS_TOPIC \
        --observability-address $OBS_ADDRESS $TRACE_TO_EVENTS_INPUT_MODE \
        --otel-endpoint $OTEL_ENDPOINT \
        $TTE_INPUT_MODE  &
}

run_aggregator() {
    BROKER="$1"
    DIGITIZERS="$2"
    DIGITIZER_EVENTS_TOPIC="$3"
    FRAME_EVENTS_TOPIC="$4"
    GROUP=$5

    echo "--" "--" "Executing aggregator"
    $EVENT_AGGREGATOR \
        --broker $BROKER --group $GROUP \
        --input-topic $DIGITIZER_EVENTS_TOPIC --output-topic $FRAME_EVENTS_TOPIC \
        --otel-endpoint $OTEL_ENDPOINT \
        --frame-ttl-ms 500 \
        $DIGITIZERS &
}

run_nexus_writer() {
    BROKER="$1"
    FRAME_EVENTS_TOPIC="$2"
    CONTROL_TOPIC="$3"

    echo "--" "--" "Executing nexus-writer"
    $NEXUS_WRITER \
        --broker $BROKER --consumer-group nexus-writer --observability-address "127.0.0.1:9091" \
        --control-topic $CONTROL_TOPIC \
        --frame-event-topic $FRAME_EVENTS_TOPIC \
        --log-topic $CONTROL_TOPIC \
        --sample-env-topic $CONTROL_TOPIC \
        --alarm-topic $CONTROL_TOPIC \
        --cache-run-ttl-ms 4000 \
        --otel-endpoint $OTEL_ENDPOINT \
        --file-name .vscode/Benchmark/HiFiOutput &
}

run_trace_simulator() {
    BROKER="$1"
    TRACE_TOPIC="$2"

    $SIMULATOR \
        --broker $BROKER \
        --trace-topic $TRACE_TOPIC \
        --otel-endpoint $OTEL_ENDPOINT \
        defined ".vscode/Benchmark/data.json" \
        --repeat=1
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