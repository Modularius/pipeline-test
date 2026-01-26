
send_run_start() {
    RUN_NAME=$1
    INSTRUMENT_NAME=$2
    TIME="$3"

    $g_SIMULATOR --broker $g_BROKER \
        --trace-topic $g_TRACE_TOPIC \
        --event-topic $g_DAT_EVENT_TOPIC \
        --frame-event-topic $g_FRAME_EVENT_TOPIC \
        --control-topic $g_CONTROL_TOPIC \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL_SIM \
        start $TIME \
        --run-name $RUN_NAME \
        --topic $g_CONTROL_TOPIC \
        --instrument-name $INSTRUMENT_NAME
}

send_logdata() {
    SOURCE_NAME="$1"
    VALUE_TYPE="$2"
    VALUE="$3"

    $g_RUN_SIMULATOR --broker $g_BROKER --topic $g_CONTROL_TOPIC \
        --run-name $RUN_NAME \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL \
        $TIME \
        log \
            --source-name "$SOURCE_NAME" \
            --value-type "$VALUE_TYPE" \
            $VALUE
}

send_selog() {
    SOURCE_NAME="$1"
    VALUE_TYPE="$2"
    VALUE="$3"

    $g_RUN_SIMULATOR --broker $g_BROKER --topic $g_CONTROL_TOPIC \
        --run-name $RUN_NAME \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL \
        $TIME \
        sample-env \
            --name "$SOURCE_NAME" \
            --values-type "$VALUE_TYPE" \
            --location "unknown" \
            "$VALUE"
}

send_alarm() {
    SOURCE_NAME="$1"
    SEVERITY="$2"
    MESSAGE="$3"

    $g_RUN_SIMULATOR --broker $g_BROKER --topic $g_CONTROL_TOPIC \
        --run-name $RUN_NAME \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL \
        $TIME \
        alarm \
            --source-name "$SOURCE_NAME" \
            --severity "$SEVERITY" \
            --message "$MESSAGE"
}

send_run_stop() {
    RUN_NAME=$1
    TIME="$3"

    $g_SIMULATOR --broker $g_BROKER \
        --trace-topic $g_TRACE_TOPIC \
        --event-topic $g_DAT_EVENT_TOPIC \
        --frame-event-topic $g_FRAME_EVENT_TOPIC \
        --control-topic $g_CONTROL_TOPIC \
        $g_OTEL_ENDPOINT \
        $g_OTEL_LEVEL_SIM \
        stop $TIME \
        --run-name $RUN_NAME \
        --topic $g_CONTROL_TOPIC
}