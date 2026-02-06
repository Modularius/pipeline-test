## Setup Pipeline
. ./Settings/Pipeline.sh

### Enact Event Formation Configuration
. ./Settings/EventFormation.sh

### Enact Observability and Logging Configuration
. ./Settings/Observability.sh

### Enact Execution Configuration
. ./Settings/Execution.sh

### Enact Broker Configuration
. ./Settings/Local/Broker.sh

. ./Scripts/deploy.sh
. ./Scripts/set_variables.sh
. ./Scripts/teardown.sh

read_message_range() {
    TOPIC="$1"; shift;
    FROM="$1"; shift;
    NUM="$1"; shift;
    rpk topic consume ${TOPIC} -n ${NUM} -o @${FROM} --format "%v{hex}"
}

resend_message_range() {
    FROM_TOPIC="$1"; shift;
    TO_TOPIC="$1"; shift;
    FROM="$1"; shift;
    NUM="$1"; shift;
    echo "Resending $NUM message(s) from topic: $FROM_TOPIC, to topic: $TO_TOPIC, from $FROM"
    read_message_range ${FROM_TOPIC} ${FROM} ${NUM} | rpk topic produce ${TO_TOPIC} --allow-auto-topic-creation --format "%v{hex}" --key "Resent"
}

read_messages_in_duration() {
    TOPIC="$1"; shift;
    FROM="$1"; shift;
    TO="$1"; shift;
    rpk topic consume ${TOPIC} -o @${FROM}:${TO} --format "%v{hex}"
}

resend_messages_in_duration() {
    FROM_TOPIC="$1"; shift;
    TO_TOPIC="$1"; shift;
    FROM="$1"; shift;
    TO="$1"; shift;
    echo "Resending $NUM message(s) from topic: $FROM_TOPIC, to topic: $TO_TOPIC, from $FROM to $TO"
    read_messages_in_duration ${FROM_TOPIC} ${FROM} ${TO} | rpk topic produce ${TO_TOPIC} --allow-auto-topic-creation --format "%v{hex}" --key "Resent"
}


RUN_203528_NUMBER=00203528
RUN_203528_START_TIMESTAMP=1760616832827
RUN_203528_STOP_TIMESTAMP=1760618004000
RUN_203528_TIMESTAMP=1760616832000

RUN_203529_NUMBER=00203529
RUN_203529_START_TIMESTAMP=1760618977200
RUN_203529_STOP_TIMESTAMP=1760620257834
RUN_203529_TIMESTAMP=1760618977000

RUN_203530_NUMBER=00203530
RUN_203530_START_TIMESTAMP=1760620262575
RUN_203530_STOP_TIMESTAMP=1760620537098
RUN_203530_TIMESTAMP=1760620262575

RUN_203548_NUMBER=00203548
RUN_203548_START_TIMESTAMP=1760672151873
RUN_203548_STOP_TIMESTAMP=1760675570844
RUN_203548_TIMESTAMP=1760672151873

RUN_203551_NUMBER=00203551
RUN_203551_START_TIMESTAMP=1760682422346
RUN_203551_STOP_TIMESTAMP=1760685842491
RUN_203551_TIMESTAMP=1760682422346

RUN_203552_NUMBER=00203552
RUN_203552_START_TIMESTAMP=1760685846939
RUN_203552_STOP_TIMESTAMP=1760688772185
RUN_203552_TIMESTAMP=1760685846000

RUN_NUMBER=$RUN_203551_NUMBER
RUN_START_TIMESTAMP=$RUN_203551_START_TIMESTAMP
RUN_STOP_TIMESTAMP=$RUN_203551_STOP_TIMESTAMP
RUN_TIMESTAMP=$RUN_203551_TIMESTAMP

RUN_FILE=HIFI${RUN_NUMBER}.nxs

run_repeat_set_ef_settings() {
    EF_INPUT_MODE=$1;shift;
    EF_THRESHOLD=$1;shift;
    EF_DURATION=$1;shift;
    EF_COOLOFF=$1;shift;
    EF_CONSTANT_MULTIPLE=$1;shift;

    ## As we have changed EF env variables we should run this again.
    set_input_mode
    set_config_opts
}

run_repeat_init() {
    MY_PIPELINE_NAME=$1;shift;

    set -u
    teardown_pipeline "test"

    set_test_pipeline_local_variables "test" "test" $MY_PIPELINE_NAME

    reset_pipeline
    echo "Removing all messages in $DAT_EVENT_TOPIC and $FRAME_EVENT_TOPIC"
    rpk topic trim-prefix $DAT_EVENT_TOPIC --no-confirm -o end
    rpk topic trim-prefix $FRAME_EVENT_TOPIC --no-confirm -o end
    echo "Deleting groups ${GROUP_AGGREGATOR} ${GROUP_WRITER}"
    rpk group delete ${GROUP_AGGREGATOR} ${GROUP_WRITER}
    echo "Seeking topic $TRACE_TOPIC in group ${GROUP_EVENT_FORMATION}"
    rpk group seek ${GROUP_EVENT_FORMATION} --to start --topics $TRACE_TOPIC --allow-new-topics
    #rpk group seek ${GROUP_EVENT_FORMATION} --to $RUN_TIMESTAMP --topics $TRACE_TOPIC --allow-new-topics
    #rpk group seek ${GROUP_AGGREGATOR} --to start --topics $DAT_EVENT_TOPIC --allow-new-topics
    #rpk group seek ${GROUP_WRITER} --to end --allow-new-topics
}

run_repeat_main() {
    set -u

    echo "Running test with ${EF_INPUT_MODE} ${EF_THRESHOLD} ${EF_DURATION} ${EF_COOLOFF} ${EF_CONSTANT_MULTIPLE}"
    
    deploy_pipeline "test"

    sleep 1

    resend_message_range $g_CONTROL_TOPIC $CONTROL_TOPIC $RUN_START_TIMESTAMP 1

    echo "Waiting until $NEXUS_LOCAL_HOST_PATH/$RUN_FILE is written"

    until [ -f "$NEXUS_LOCAL_HOST_PATH/$RUN_FILE" ]; do
        sleep 1
    done

    resend_message_range $g_CONTROL_TOPIC $CONTROL_TOPIC $RUN_STOP_TIMESTAMP 1

    resend_messages_in_duration $g_LOGS_TOPIC $LOGS_TOPIC $RUN_START_TIMESTAMP $RUN_STOP_TIMESTAMP
    resend_messages_in_duration $g_SELOGS_TOPIC $SELOGS_TOPIC $RUN_START_TIMESTAMP $RUN_STOP_TIMESTAMP
    resend_messages_in_duration $g_ALARMS_TOPIC $ALARMS_TOPIC $RUN_START_TIMESTAMP $RUN_STOP_TIMESTAMP

    echo "Waiting until $NEXUS_LOCAL_HOST_PATH/completed/$RUN_FILE is written"
    until [ -f "$NEXUS_LOCAL_HOST_PATH/completed/$RUN_FILE" ]; do
        sleep 1
    done

    echo "Waiting until $NEXUS_ARCHIVE_HOST_PATH/$RUN_FILE is written"
    until [ -f "$NEXUS_ARCHIVE_HOST_PATH/$RUN_FILE" ]; do
        sleep 1
    done
    echo "Waiting until $NEXUS_LOCAL_HOST_PATH/completed/$RUN_FILE is fully transferred"
    while [ -f "$NEXUS_LOCAL_HOST_PATH/completed/$RUN_FILE" ]; do
        sleep 1
    done
    sleep 5

    teardown_pipeline "test"
}

run_repeat_with_ef() {
    MY_PIPELINE_NAME=$1;shift;
    set -a -u

    run_repeat_init $MY_PIPELINE_NAME
    run_repeat_set_ef_settings "${@}"
    run_repeat_main
}