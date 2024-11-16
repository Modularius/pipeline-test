g_SIMULATOR_CONFIG_SOURCE="Simulations/test.json"

#export OTEL_BSP_MAX_QUEUE_SIZE=8192
teardown() {
    teardown_containerised_pipeline pipeline1
    sleep 5
    teardown_pipeline_consumer_groups pipeline1
}

deploy() {
    g_NUM_DIGITISERS=$1
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))
    g_DIGITISERS=$(build_digitiser_argument $g_MAX_DIGITISER)
    echo deploying pipeline with $g_NUM_DIGITISERS digitisers: $g_DIGITISERS

    deploy_containerised_pipeline pipeline1 8g 2g 8g local "fixed-threshold-discriminator --threshold=2200 --duration=1 --cool-off=0"
    
    sleep 5
}

execute_run() {
    g_NUM_DIGITISERS=$1
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))
    g_DIGITISERS=$(build_digitiser_argument $g_MAX_DIGITISER)
    echo deploying pipeline with $g_NUM_DIGITISERS digitisers: $g_DIGITISERS

    g_RUN_NAME=$2
    export g_MAX_DIGITISER
    export g_NUM_DIGITISERS
    export g_RUN_NAME

    echo simulator start
    deploy_containerised_simulator pipeline1 $g_SIMULATOR_CONFIG_SOURCE
    echo simulator finished

}


teardown
deploy 8
execute_run 8 LetsDoARunAgainOnceMore
teardown_containerised_simulator

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker up -d