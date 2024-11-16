g_SIMULATOR_CONFIG_SOURCE="Simulations/test.json"

#export OTEL_BSP_MAX_QUEUE_SIZE=8192
teardown() {
    PIPELINE_NAME=$1;shift;

    teardown_containerised_pipeline $PIPELINE_NAME
    sleep 5
    teardown_pipeline_consumer_groups $PIPELINE_NAME
}

deploy() {
    PIPELINE_NAME=$1;shift;
    EF_INDEX=$1;shift;
    DA_INDEX=$1;shift;
    NW_INDEX=$1;shift;
    
    g_NUM_DIGITISERS=$1;shift;
    TTE_INPUT_MODE=$1;shift;


    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))
    g_DIGITISERS=$(build_digitiser_argument $g_MAX_DIGITISER)
    echo deploying pipeline with $g_NUM_DIGITISERS digitisers: $g_DIGITISERS

    deploy_containerised_pipeline $PIPELINE_NAME $EF_INDEX $DA_INDEX $NW_INDEX 8g 2g 8g "local_" ${TTE_INPUT_MODE}

    sleep 5
}

execute_run() {
    PIPELINE_NAME=$1;shift;

    g_NUM_DIGITISERS=$1;shift;
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))

    g_RUN_NAME=$1;shift;
    export g_MAX_DIGITISER
    export g_NUM_DIGITISERS
    export g_RUN_NAME

    echo simulator start
    deploy_containerised_simulator $PIPELINE_NAME $g_SIMULATOR_CONFIG_SOURCE
    echo simulator finished

}


teardown pipeline1
teardown pipeline2
deploy pipeline1 0 1 2 8 "fixed-threshold-discriminator --threshold=2200 --duration=1 --cool-off=0"
deploy pipeline2 3 4 5 8 "fixed-threshold-discriminator --threshold=2400 --duration=1 --cool-off=0"
execute_run pipeline1 8 LetsDoARun
teardown_containerised_simulator

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker up -d