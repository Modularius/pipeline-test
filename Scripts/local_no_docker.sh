g_SIMULATOR_CONFIG_SOURCE="Simulations/test.json"

#export OTEL_BSP_MAX_QUEUE_SIZE=8192

execute_run() {
    g_NUM_DIGITISERS=$1;shift;
    g_MAX_DIGITISER=$(($g_NUM_DIGITISERS - 1))

    g_RUN_NAME=$1;shift;
    export g_MAX_DIGITISER
    export g_NUM_DIGITISERS
    export g_RUN_NAME

    sudo mkdir $g_NEXUS_ARCHIVE_PATH --mode=666
    sudo mkdir $g_NEXUS_OUTPUT_PATH --mode=666

    kill_persistant_components

    sleep 3

    run_persistant_components

    sleep 3

    run_trace_simulator "$g_SIMULATOR" \
        $g_BROKER $g_CONTROL_TOPIC $g_TRACE_TOPIC $g_DAT_EVENT_TOPIC $g_FRAME_EVENT_TOPIC \
        $g_OBSV_ADDRESS "$g_OTEL_ENDPOINT" "$g_OTEL_LEVEL_SIM" \
        $g_SIMULATOR_CONFIG_SOURCE

}

execute_run 8 CantOddOrEvenBabe
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker up -d