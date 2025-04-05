run_trace_to_events() {
    echo "Using detector settings '$g_TTE_INPUT_COMMAND'"

    echo "--" "--" "Executing Event Formation"
    CMD="$g_TRACE_TO_EVENTS \
        --broker $g_BROKER --consumer-group $g_GROUP_EVENT_FORMATION \
        --observability-address $g_OBSV_ADDRESS_EVENT_FORMATION \
        --trace-topic $g_TRACE_TOPIC \
        --event-topic $g_DAT_EVENT_TOPIC \
        --polarity $g_TTE_POLARITY \
        --baseline $g_TTE_BASELINE \
        --otel-endpoint $g_OTEL_ENDPOINT \
        --otel-namespace=$g_PIPELINE_NAME \
        $g_TTE_INPUT_COMMAND"
        
    echo $CMD
    RUST_LOG=$g_RUST_LOG OTEL_LEVEL=$g_OTEL_LEVEL NO_COLOR=$g_NO_COLOR $CMD &
}
#--save-file Output/MuSR/output_ \

run_aggregator() {
    echo "--" "--" "Executing aggregator"

    CMD="$g_EVENT_AGGREGATOR \
        --broker $g_BROKER --group $g_GROUP_AGGREGATOR \
        --input-topic $g_DAT_EVENT_TOPIC --output-topic $g_FRAME_EVENT_TOPIC \
        --observability-address $g_OBSV_ADDRESS_AGGREGATOR \
        --frame-ttl-ms $g_FRAME_TTL_MS \
        --send-frame-buffer-size 4000 \
        --otel-endpoint $g_OTEL_ENDPOINT \
        --otel-namespace=$g_PIPELINE_NAME \
        $g_DIGITISERS"
        
    echo $CMD
    RUST_LOG=$g_RUST_LOG OTEL_LEVEL=$g_OTEL_LEVEL NO_COLOR=$g_NO_COLOR $CMD &
}

run_nexus_writer() {
    echo "--" "--" "Executing nexus-writer"
    
    CMD="$g_NEXUS_WRITER \
        --broker $g_BROKER --consumer-group $g_GROUP_WRITER \
        --observability-address $g_OBSV_ADDRESS_WRITER \
        --control-topic $g_CONTROL_TOPIC \
        --frame-event-topic $g_FRAME_EVENT_TOPIC \
        --log-topic $g_CONTROL_TOPIC \
        --sample-env-topic $g_SELOGS_TOPIC \
        --alarm-topic $g_CONTROL_TOPIC \
        --cache-run-ttl-ms 5000 \
        --otel-endpoint $g_OTEL_ENDPOINT \
        --otel-namespace=$g_PIPELINE_NAME \
        --local-path ${g_NEXUS_OUTPUT_PATH} \
        --archive-path ${g_NEXUS_ARCHIVE_PATH}"
#        --file-name ${g_NEXUS_OUTPUT_PATH} \
#        --archive-name ${g_NEXUS_ARCHIVE_PATH}"

    echo $CMD
    RUST_LOG=$g_RUST_LOG OTEL_LEVEL=$g_OTEL_LEVEL NO_COLOR=$g_NO_COLOR $CMD &
}
