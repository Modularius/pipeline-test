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
        $OTEL_ENDPOINT \
        $OTEL_LEVEL_EVENT_FORMATION \
        $TTE_INPUT_MODE  &
}
#        --save-file Output/HiFi/output_ \

build_digitiser_argument() {
    MAX_DIGITISER=$1
    DIGITIZERS=""
    for I in $(seq 0 1 $MAX_DIGITISER)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    echo "$DIGITIZERS"
}

run_aggregator() {
    echo "--" "--" "Executing aggregator"

    $EVENT_AGGREGATOR \
        --broker $BROKER --group $GROUP_AGGREGATOR \
        --input-topic $DAT_EVENT_TOPIC --output-topic $FRAME_EVENT_TOPIC \
        --observability-address "127.0.0.1:29091" \
        --frame-ttl-ms 2000 \
        $OTEL_ENDPOINT \
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
        $OTEL_ENDPOINT \
        $OTEL_LEVEL_WRITER \
        --file-name "$NEXUS_OUTPUT_PATH"  &
}
#\
#        --archive-name "$NEXUS_ARCHIVE_PATH"
