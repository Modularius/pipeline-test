reset_pipeline() {
    mkdir $NEXUS_ARCHIVE_HOST_PATH $NEXUS_LOCAL_HOST_PATH $NEXUS_ARCHIVE_HOST_PATH/logs
    touch $NEXUS_ARCHIVE_HOST_PATH/logs/nexus-writer.log $NEXUS_ARCHIVE_HOST_PATH/logs/digitiser-aggregator.log $NEXUS_ARCHIVE_HOST_PATH/logs/event-formation.log
    
    rm $NEXUS_LOCAL_HOST_PATH/*.nxs
    rm $NEXUS_LOCAL_HOST_PATH/completed/*.nxs
    
    rpk topic create $DAT_EVENT_TOPIC -c retention.ms=Infinite
    rpk topic create $FRAME_EVENT_TOPIC -c retention.bytes=100MiB
}

deploy_pipeline() {
    LOCAL_PIPELINE_NAME=$1;shift;
    if [ -v LOCAL_PIPELINE_NAME ]; then
        PIPELINE_NAME=${g_PIPELINE_NAME}_${LOCAL_PIPELINE_NAME}
    else
        PIPELINE_NAME=${g_PIPELINE_NAME}
    fi
    set -u

    echo deploying pipeline $PIPELINE_NAME
    
    cat Compose/pipeline.template.yml | envsubst > Compose/pipeline.yml
    podman-compose -f Compose/pipeline.yml --profile main -p ${PIPELINE_NAME} --verbose up -d
}