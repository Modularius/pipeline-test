build_common_podman_parameters() {
    MEMORY=$1;shift;
    RESTART=$1;shift;
    LOG_MAX_SIZE=$1;shift;
    RUST_LOG=$1;shift;
    NAME=$1;shift;

    --memory ${MEMORY} \
    --restart ${RESTART} \
    --log-opt max-size=${LOG_MAX_SIZE} \
    --env RUST_LOG=${RUST_LOG} \
    --name=${NAME}
}