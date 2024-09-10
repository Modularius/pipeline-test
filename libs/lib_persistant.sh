
#TRACE_TO_EVENTS="cargo run --release --bin trace-to-events --"
#EVENT_AGGREGATOR="cargo run --release --bin digitiser-aggregator --"
#NEXUS_WRITER="cargo run --release --bin nexus-writer --"

TRACE_TO_EVENTS="../supermusr-data-pipeline/target/release/trace-to-events"
NEXUS_WRITER="../supermusr-data-pipeline/target/release/nexus-writer"
EVENT_AGGREGATOR="../supermusr-data-pipeline/target/release/digitiser-aggregator"

#        --save-file Output/HiFi/output_ \

run_trace_to_events() {
    echo "Using detector settings '$TTE_INPUT_MODE'"

    echo "--" "--" "Executing Event Formation"
    $TRACE_TO_EVENTS \
        --broker $BROKER --consumer-group $GROUP_EVENT_FORMATION \
        --observability-address "127.0.0.1:29094" \
        --trace-topic $TRACE_TOPIC \
        --event-topic $DAT_EVENT_TOPIC \
        --polarity $TTE_POLARITY \
        --baseline $TTE_BASELINE \
        --otel-endpoint $OTEL_ENDPOINT \
        $OTEL_LEVEL_EVENT_FORMATION \
        $TTE_INPUT_MODE  &
}

run_aggregator() {
    echo "--" "--" "Executing aggregator"

    $EVENT_AGGREGATOR \
        --broker $BROKER --group $GROUP_AGGREGATOR \
        --input-topic $DAT_EVENT_TOPIC --output-topic $FRAME_EVENT_TOPIC \
        --observability-address "127.0.0.1:29091" \
        --frame-ttl-ms 2000 \
        --otel-endpoint $OTEL_ENDPOINT \
        $OTEL_LEVEL_AGGREGATOR \
        $DIGITIZERS &
}

run_nexus_writer() {
    echo "--" "--" "Executing nexus-writer"
    
    $NEXUS_WRITER \
        --broker $BROKER --consumer-group "$GROUP_WRITER" \
        --observability-address "127.0.0.1:29090" \
        --control-topic $CONTROL_TOPIC \
        --frame-event-topic $FRAME_EVENT_TOPIC \
        --log-topic $CONTROL_TOPIC \
        --sample-env-topic $CONTROL_TOPIC \
        --alarm-topic $CONTROL_TOPIC \
        --cache-run-ttl-ms 5000 \
        --otel-endpoint $OTEL_ENDPOINT \
        $OTEL_LEVEL_WRITER \
        --file-name "$NEXUS_OUTPUT_PATH" &
}

