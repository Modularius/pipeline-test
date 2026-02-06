
send_run_start() {
    RUN_NAME=$1
    INSTRUMENT_NAME=$2
    TIME="$3"

    $SIMULATOR --broker $BROKER \
        --trace-topic $TRACE_TOPIC \
        --event-topic $DAT_EVENT_TOPIC \
        --frame-event-topic $FRAME_EVENT_TOPIC \
        --control-topic $CONTROL_TOPIC \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL_SIM \
        start $TIME \
        --run-name $RUN_NAME \
        --topic $CONTROL_TOPIC \
        --instrument-name $INSTRUMENT_NAME
}

send_logdata() {
    SOURCE_NAME="$1"
    VALUE_TYPE="$2"
    VALUE="$3"

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL \
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

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL \
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

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL \
        $TIME \
        alarm \
            --source-name "$SOURCE_NAME" \
            --severity "$SEVERITY" \
            --message "$MESSAGE"
}

send_run_stop() {
    RUN_NAME=$1
    TIME="$3"

    $SIMULATOR --broker $BROKER \
        --trace-topic $TRACE_TOPIC \
        --event-topic $DAT_EVENT_TOPIC \
        --frame-event-topic $FRAME_EVENT_TOPIC \
        --control-topic $CONTROL_TOPIC \
        $OTEL_ENDPOINT \
        $OTEL_LEVEL_SIM \
        stop $TIME \
        --run-name $RUN_NAME \
        --topic $CONTROL_TOPIC
}