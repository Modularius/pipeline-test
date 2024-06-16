#RUN_SIMULATOR="cargo run --release --bin run-simulator --"
RUN_SIMULATOR="../supermusr-data-pipeline/target/release/run-simulator"

send_run_start() {
    RUN_NAME=$1
    INSTRUMENT_NAME=$2
    TIME="$3"

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        --otel-endpoint $OTEL_ENDPOINT \
        $OTEL_LEVEL \
        $TIME \
        start --instrument-name $INSTRUMENT_NAME
}

send_logdata() {
    SOURCE_NAME="$1"
    VALUE_TYPE="$2"
    VALUE="$3"

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        --otel-endpoint $OTEL_ENDPOINT \
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
        --otel-endpoint $OTEL_ENDPOINT \
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
        --otel-endpoint $OTEL_ENDPOINT \
        $OTEL_LEVEL \
        $TIME \
        alarm \
            --source-name "$SOURCE_NAME" \
            --severity "$SEVERITY" \
            --message "$MESSAGE"
}

send_run_stop() {
    RUN_NAME=$1
    INSTRUMENT_NAME=$2

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        --otel-endpoint $OTEL_ENDPOINT \
        $OTEL_LEVEL \
        $TIME \
        stop
}
