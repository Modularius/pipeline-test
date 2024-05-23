#RUN_SIMULATOR="cargo run --release --bin run-simulator --"
RUN_SIMULATOR="target/release/run-simulator"

send_run_start() {
    RUN_NAME=$1
    INSTRUMENT_NAME=$2

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        --otel-endpoint $OTEL_ENDPOINT \
        start --instrument-name $INSTRUMENT_NAME
}

send_logdata() {
    RUN_NAME=$1
    INSTRUMENT_NAME=$2

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        --otel-endpoint $OTEL_ENDPOINT \
        log \
            --source-name $SOURCE_NAME \
            --value-type $VALUE_TYPE \
            $VALUE
}

send_selog() {
    RUN_NAME=$1
    INSTRUMENT_NAME=$2

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        --otel-endpoint $OTEL_ENDPOINT \
        sample-env \
            --name $SOURCE_NAME \
            --values-type $VALUE_TYPE \
            --location "unknown" \
            $VALUE
}

send_alarm() {
    RUN_NAME=$1
    INSTRUMENT_NAME=$2

    $RUN_SIMULATOR --broker $BROKER --topic $CONTROL_TOPIC \
        --run-name $RUN_NAME \
        --otel-endpoint $OTEL_ENDPOINT \
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
        stop
}
