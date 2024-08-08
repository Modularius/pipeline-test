BROKER="localhost:9092"
TRACE_TOPIC=Traces
DAT_EVENT_TOPIC=Events
FRAME_EVENT_TOPIC=FrameEvents
CONTROL_TOPIC=Controls
LOGS_TOPIC=Logs
SELOGS_TOPIC=SELogs
ALARMS_TOPIC=Alarms

GROUP_WRITER=nexus-writer
GROUP_AGGREGATOR=digitiser-aggregator
GROUP_EVENT_FORMATION=trace-to-events

PROCESS_WRITER=nexus-writer
PROCESS_AGGREGATOR=digitiser-aggre
PROCESS_EVENT_FORMATION=trace-to-events

INPUT=simulator
SIMULATOR_CONFIG_SOURCE="simulator_configs/test.json"
#SIMULATOR_CONFIG_SOURCE="simulator_configs/full_frame.json"
#TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
TTE_POLARITY=positive
TTE_BASELINE=0
TTE_INPUT_MODE="fixed-threshold-discriminator --threshold=10 --duration=1 --cool-off=0"

NEXUS_OUTPUT_PATH="Output/Local"
OTEL_LEVEL="--otel-level=info"
#OTEL_LEVEL="info"

export RUST_LOG=warn,digitiser_aggregator=warn,nexus_writer=warn,trace_to_events=warn,$RUST_LOG_OFF
export OTEL_BSP_MAX_QUEUE_SIZE=8192


. ./libs/lib.sh

kill_persistant_components

sleep 5

rpk topic create $TRACE_TOPIC $DAT_EVENT_TOPIC $FRAME_EVENT_TOPIC $CONTROL_TOPIC $LOGS_TOPIC $SELOGS_TOPIC $ALARMS_TOPIC
rpk group delete trace-to-events digitiser-aggregator nexus-writer

sleep 2

run_trace_to_events
run_nexus_writer


build_digitiser_argument() {
    MAX_DIGITISER=$1
    DIGITIZERS=""
    for I in $(seq 0 1 $MAX_DIGITISER)
    do
        DIGITIZERS=$DIGITIZERS" -d$I"
    done
    echo "$DIGITIZERS"
}

wait_for_input() {
    echo press any key to continue
    while true; do
        read -rsn1 key  # Read a single character silently
        if [[ -n "$key" ]]; then
            break  # Exit the loop if a key is pressed
        fi
    done
}

execute_run() {
    NUM_DIGITISERS=$1
    MAX_DIGITISER=$(($NUM_DIGITISERS - 1))
    DIGITIZERS=$(build_digitiser_argument $MAX_DIGITISER)
    echo executing run with $NUM_DIGITISERS digitisers

    run_aggregator

    sleep 3

    RUN_NAME=$2
    export MAX_DIGITISER
    export NUM_DIGITISERS
    export RUN_NAME

    run_trace_simulator
    
    wait_for_input
    pkill $PROCESS_AGGREGATOR
    sleep 1
}

#execute_run 8 Run1
#execute_run 16 Run2
#execute_run 24 Run3
#execute_run 32 Run4
#execute_run 40 Run5
execute_run 48 Run6
execute_run 56 Run7
execute_run 64 Run8
execute_run 72 Run9
execute_run 80 Run10
#execute_run 88 Run11
#execute_run 96 Run12
#execute_run 104 Run13
#execute_run 112 Run14
#execute_run 120 Run15
#execute_run 128 Run16

#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=all down
#docker compose --env-file ./configs/.env.local -f "./configs/docker-compose.yaml" --profile=no-broker up -d