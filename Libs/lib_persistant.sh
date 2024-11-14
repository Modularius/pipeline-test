run_trace_to_events() {
    echo "Using detector settings '$g_TTE_INPUT_MODE'"

    echo "--" "--" "Executing Event Formation"
    $g_TRACE_TO_EVENTS \
        --broker $g_BROKER --consumer-group $g_GROUP_EVENT_FORMATION \
        --observability-address "127.0.0.1:29094" \
        --trace-topic $g_TRACE_TOPIC \
        --event-topic $g_DAT_EVENT_TOPIC \
        --polarity $g_TTE_POLARITY \
        --baseline $g_TTE_BASELINE \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL_EVENT_FORMATION \
        $g_TTE_INPUT_MODE  &
        #        --save-file Output/HiFi/output_ \
}

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

    $g_EVENT_AGGREGATOR \
        --broker $g_BROKER --group $g_GROUP_AGGREGATOR \
        --input-topic $g_DAT_EVENT_TOPIC --output-topic $g_FRAME_EVENT_TOPIC \
        --observability-address "127.0.0.1:29091" \
        --frame-ttl-ms 2000 \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL_AGGREGATOR \
        $g_DIGITIZERS &
}

run_nexus_writer() {
    echo "--" "--" "Executing nexus-writer"
    
    $g_NEXUS_WRITER \
        --broker $g_BROKER --consumer-group "$g_GROUP_WRITER" \
        --observability-address "127.0.0.1:29090" \
        --control-topic $g_CONTROL_TOPIC \
        --frame-event-topic $g_FRAME_EVENT_TOPIC \
        --log-topic $g_CONTROL_TOPIC \
        --sample-env-topic $g_CONTROL_TOPIC \
        --alarm-topic $g_CONTROL_TOPIC \
        --cache-run-ttl-ms 5000 \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL_WRITER \
        --file-name "g_$NEXUS_OUTPUT_PATH" &
}

