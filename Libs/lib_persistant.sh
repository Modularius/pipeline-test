run_trace_to_events() {
    echo "Using detector settings '$TTE_INPUT_MODE'"

    echo "--" "--" "Executing Event Formation : $TRACE_TO_EVENTS"
    $TRACE_TO_EVENTS \
        --broker $BROKER --consumer-group $GROUP_EVENT_FORMATION \
        --observability-address "$OBSV_ADDRESS" \
        --trace-topic $TRACE_TOPIC \
        --event-topic $DAT_EVENT_TOPIC \
        --polarity $EF_POLARITY \
        --baseline $EF_BASELINE \
        $OTEL_ENDPOINT \
        --otel-namespace $PIPELINE_NAME \
        $OTEL_LEVEL_EVENT_FORMATION \
        $EF_INPUT_MODE
}
#--save-file output_ \

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
    echo "--" "--" "Executing aggregator : $EVENT_AGGREGATOR"

    $EVENT_AGGREGATOR \
        --broker $BROKER --group $GROUP_AGGREGATOR \
        --input-topic $DAT_EVENT_TOPIC --output-topic $FRAME_EVENT_TOPIC \
        --observability-address "$OBSV_ADDRESS" \
        --frame-ttl-ms $FRAME_TTL_MS \
        --send-frame-buffer-size $FRAME_BUFFER_SIZE \
        $OTEL_ENDPOINT \
        --otel-namespace $PIPELINE_NAME \
        $OTEL_LEVEL_AGGREGATOR \
        $DIGITIZERS
}

run_nexus_writer() {
    echo "--" "--" "Executing nexus-writer: $NEXUS_WRITER"

    echo "OTEL WRITER: $OTEL_LEVEL_WRITER"
    
    $NEXUS_WRITER \
        --broker $BROKER --consumer-group "test" \
        --observability-address "$OBSV_ADDRESS" \
        --control-topic $CONTROL_TOPIC \
        --frame-event-topic $FRAME_EVENT_TOPIC \
        --log-topic $CONTROL_TOPIC \
        --sample-env-topic $CONTROL_TOPIC \
        --alarm-topic $CONTROL_TOPIC \
        --cache-run-ttl-ms $RUN_TTL_MS \
        $OTEL_ENDPOINT \
        --otel-namespace $PIPELINE_NAME \
        $OTEL_LEVEL_WRITER \
        --configuration-options "${CONFIGURATION_OPTIONS}" \
        --file-name "$NEXUS_LOCAL_PATH" \
        --archive-name "$NEXUS_ARCHIVE_PATH"
}

