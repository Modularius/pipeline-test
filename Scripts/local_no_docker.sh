
SIMULATOR_CONFIG_SOURCE="Simulations/test.json"

#export OTEL_BSP_MAX_QUEUE_SIZE=8192

execute_run() {
    kill_persistant_components

    #sleep 1

    #rpk topic delete $TRACE_TOPIC $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC $CONTROL_TOPIC $LOGS_TOPIC $SELOGS_TOPIC $ALARMS_TOPIC
    #rpk topic create $TRACE_TOPIC $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC $CONTROL_TOPIC $LOGS_TOPIC $SELOGS_TOPIC $ALARMS_TOPIC
    rpk topic trim $TRACE_TOPIC --offset end --no-confirm
    #rpk topic trim $CONTROL_TOPIC --offset end --no-confirm
    
    #sleep 1

    NUM_DIGITISERS=$1
    MAX_DIGITISER=$(($NUM_DIGITISERS - 1))
    DIGITIZERS=$(build_digitiser_argument $MAX_DIGITISER)
    echo executing run with $NUM_DIGITISERS digitisers: $DIGITIZERS

    RUN_NAME=$2
    export MAX_DIGITISER
    export NUM_DIGITISERS
    export RUN_NAME

    run_persistant_components
    sleep 2

    echo simulator start
    run_trace_simulator
    echo simulator finished

    #rpk group seek $GROUP_EVENT_FORMATION --to 1622505600
    #rpk group seek $GROUP_WRITER --to 1622505600
}

#send_run_start "MyRun" "MuSR"

execute_run 8 LetsDoARun
#execute_run 16 Run16
#execute_run 24 Run3
#execute_run 32 Run32
#execute_run 40 Run5
#execute_run 48 Run48
#execute_run 56 Run7
#execute_run 64 Run64
#execute_run 72 Run9
#execute_run 80 Run80
#execute_run 88 Run11
#execute_run 96 Run96
#execute_run 104 Run13
#execute_run 112 Run14
#execute_run 120 Run15
#execute_run 128 Run16

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker up -d