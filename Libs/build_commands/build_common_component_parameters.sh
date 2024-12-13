build_common_podman_parameters() {
    BROKER=$1;shift;
    GROUP=$1;shift;

    PIPELINE_NAME=$1;shift;
    OBSV_ADDRESS=$1;shift;
    OTEL_ENDPOINT=$1;shift;
    OTEL_LEVEL=$1;shift;
\
    --broker $BROKER
    --consumer-group $GROUP \
    --observability-address "$OBSV_ADDRESS"1 \
    --otel-endpoint $OTEL_ENDPOINT \
    --otel-namespace $PIPELINE_NAME \
    --otel-level $OTEL_LEVEL
}