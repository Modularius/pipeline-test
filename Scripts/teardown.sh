teardown_pipeline() {
    LOCAL_PIPELINE_NAME=$1;shift;
    if [ -v LOCAL_PIPELINE_NAME ]; then
        PIPELINE_NAME=${g_PIPELINE_NAME}_${LOCAL_PIPELINE_NAME}
    else
        PIPELINE_NAME=${g_PIPELINE_NAME}
    fi
    
    set -u
    podman-compose -f Compose/pipeline.yml -p ${PIPELINE_NAME} --profile main down
}

