. ./Libs/lib.sh

#export OTEL_BSP_MAX_QUEUE_SIZE=8192

execute_run() {
    NUM_DIGITISERS=$1;shift;
    MAX_DIGITISER=$(($NUM_DIGITISERS - 1))

    RUN_NAME=$1;shift;
    
    g_SIMULATOR_CONFIG_SOURCE=$1;shift;

    MAX_DIGITISER=$g_MAX_DIGITISER
    NUM_DIGITISERS=$g_NUM_DIGITISERS
    RUN_NAME=$g_RUN_NAME
    env=[]

    buildah run \ 
        -e MAX_DIGITISER=$MAX_DIGITISER \
        -e NUM_DIGITISERS=$NUM_DIGITISERS \
        -e RUN_NAME=$RUN_NAME \
        simulator -- "app $(simulator_params)"
}

buildah run \
    -e RUST_LOG=$g_RUST_LOG \
    -e OTEL_LEVEL=$g_OTEL_LEVEL \
    -e NO_COLOR=$g_NO_COLOR \
    trace-to-events "app/app $(trace_to_events_params)"
buildah run \
    -e RUST_LOG=$g_RUST_LOG \
    -e OTEL_LEVEL=$g_OTEL_LEVEL \
    -e NO_COLOR=$g_NO_COLOR \
    digitiser-aggregator -- $(aggregator_params)
buildah run \
    -e RUST_LOG=$g_RUST_LOG \
    -e OTEL_LEVEL=$g_OTEL_LEVEL \
    -e NO_COLOR=$g_NO_COLOR \
    nexus-writer -- "$(nexus_writer_params)"
sleep 3

execute_run 8 ShortTest "Simulations/Tests/SanityChecking/test3.json"
