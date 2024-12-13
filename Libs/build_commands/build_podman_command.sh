build_podman_command() {
    COMMAND=$1;shift;
    IMAGE_PREFIX=$1;shift;
    IMAGE=$1;shift;
    TAG=$1;shift;
    PODMAN_PARAMETERS=$1;shift;
    COMPONENT_PARAMETERS=$1;shift;

    podman ${COMMAND} ${PARAMETERS} ${IMAGE_PREFIX}${IMAGE}${TAG} ${COMPONENT_PARAMETERS}
}