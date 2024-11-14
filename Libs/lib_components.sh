## Fully Functional
build_trace_to_events_command() {

    TRACE_TO_EVENTS=$1;shift;

    BROKER=$1;shift;
    GROUP=$1;shift;
    TRACE_TOPIC=$1;shift;
    DAT_EVENT_TOPIC=$1;shift;

    OBSV_ADDRESS=$1;shift;
    OTEL_ENDPOINT=$1;shift;
    OTEL_LEVEL=$1;shift;

    TTE_POLARITY=$1;shift;
    TTE_BASELINE=$1;shift;
    TTE_INPUT_MODE=$1;shift;

    echo "Using detector settings '$TTE_INPUT_MODE'"

    echo "--" "--" "Executing Event Formation : $TRACE_TO_EVENTS"
    $TRACE_TO_EVENTS \
        --broker $BROKER --consumer-group $GROUP_EVENT_FORMATION \
        --observability-address "$OBSV_ADDRESS"0 \
        --trace-topic $TRACE_TOPIC \
        --event-topic $DAT_EVENT_TOPIC \
        --polarity $TTE_POLARITY \
        --baseline $TTE_BASELINE \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL_EVENT_FORMATION \
        $TTE_INPUT_MODE
}

## Fully Functional
build_digitiser_aggregator_command() {
    EVENT_AGGREGATOR=$1;shift;

    BROKER=$1;shift;
    GROUP=$1;shift;
    DAT_EVENT_TOPIC=$1;shift;
    FRAME_EVENT_TOPIC=$1;shift;
    FRAME_TTL_MS=$1;shift;

    OBSV_ADDRESS=$1;shift;
    OTEL_ENDPOINT=$1;shift;
    OTEL_LEVEL=$1;shift;

    DIGITIZERS=$1;shift;

    echo "--" "--" "Executing aggregator : $EVENT_AGGREGATOR"

    $EVENT_AGGREGATOR \
        --broker $BROKER --group $GROUP \
        --input-topic $DAT_EVENT_TOPIC --output-topic $FRAME_EVENT_TOPIC \
        --observability-address "$OBSV_ADDRESS"1 \
        --frame-ttl-ms $FRAME_TTL_MS \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL \
        $DIGITIZERS &
}

## Fully Functional
build_nexus_writer_command() {
    NEXUS_WRITER=$1;shift;

    BROKER=$1;shift;
    GROUP=$1;shift;
    CONTROL_TOPIC=$1;shift;
    FRAME_EVENT_TOPIC=$1;shift;
    RUN_TTL_MS=$1;shift;
    NEXUS_OUTPUT_PATH=$1;shift;
    NEXUS_ARCHIVE_PATH=$1;shift;

    OBSV_ADDRESS=$1;shift;
    OTEL_ENDPOINT=$1;shift;
    OTEL_LEVEL=$1;shift;

    DIGITIZERS=$1;shift;
    echo "--" "--" "Executing nexus-writer: $NEXUS_WRITER"
    
    $NEXUS_WRITER \
        --broker $BROKER --consumer-group "$GROUP" \
        --observability-address "$OBSV_ADDRESS"2 \
        --control-topic $CONTROL_TOPIC \
        --frame-event-topic $FRAME_EVENT_TOPIC \
        --log-topic $CONTROL_TOPIC \
        --sample-env-topic $CONTROL_TOPIC \
        --alarm-topic $CONTROL_TOPIC \
        --cache-run-ttl-ms $RUN_TTL_MS \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL_WRITER \
        --file-name "$NEXUS_OUTPUT_PATH" \
        --archive-name "$NEXUS_ARCHIVE_PATH"
}

