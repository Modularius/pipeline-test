
#TRACE_TO_EVENTS="cargo run --release --bin trace-to-events --"
#EVENT_AGGREGATOR="cargo run --release --bin digitiser-aggregator --"
#NEXUS_WRITER="cargo run --release --bin nexus-writer --"

TRACE_TO_EVENTS="../supermusr-data-pipeline/target/release/trace-to-events"
NEXUS_WRITER="../supermusr-data-pipeline/target/release/nexus-writer"
EVENT_AGGREGATOR="../supermusr-data-pipeline/target/release/digitiser-aggregator"

#--save-file output/Saves/Tests/output_ \

run_trace_to_events() {
    GROUP="$1"
    OBS_ADDRESS="$2"

    [ $INPUT = simulator ] \
    && TRACE_TO_EVENTS_INPUT_MODE="--polarity positive --baseline=0" \
    || TRACE_TO_EVENTS_INPUT_MODE="--polarity negative --baseline=100"
    TRACE_TO_EVENTS_INPUT_MODE="--polarity positive --baseline=0"

    echo "Using Input Mode '$TRACE_TO_EVENTS_INPUT_MODE' with detector settings '$TTE_INPUT_MODE'"

    echo "--" "--" "Executing Event Formation"
    $TRACE_TO_EVENTS \
        --broker $BROKER --group $GROUP \
        --trace-topic $TRACE_TOPIC \
        --event-topic $DAT_EVENT_TOPIC \
        --observability-address $OBS_ADDRESS $TRACE_TO_EVENTS_INPUT_MODE \
        --otel-endpoint $OTEL_ENDPOINT \
        $TTE_INPUT_MODE  &
}

run_aggregator() {
    GROUP="$1"

    echo "--" "--" "Executing aggregator"
    $EVENT_AGGREGATOR \
        --broker $BROKER --group $GROUP \
        --input-topic $DAT_EVENT_TOPIC --output-topic $FRAME_EVENT_TOPIC \
        --otel-endpoint $OTEL_ENDPOINT \
        --frame-ttl-ms 500 \
        $DIGITIZERS &
}

run_nexus_writer() {
    GROUP="$1"

    echo "--" "--" "Executing nexus-writer"
    RUST_LOG=info
    $NEXUS_WRITER \
        --broker $BROKER --consumer-group "$GROUP" --observability-address "127.0.0.1:9091" \
        --control-topic $CONTROL_TOPIC \
        --frame-event-topic $FRAME_EVENT_TOPIC \
        --log-topic $CONTROL_TOPIC \
        --sample-env-topic $CONTROL_TOPIC \
        --alarm-topic $CONTROL_TOPIC \
        --cache-run-ttl-ms 4000 \
        --otel-endpoint $OTEL_ENDPOINT \
        --file-name "$NEXUS_OUTPUT_PATH" &
}

