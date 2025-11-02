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
    TOPIC="$1"
    FROM="$2"
    NUM="$3"
    rpk topic consume ${TOPIC} -n ${NUM} -o @${FROM} --format "%v{hex}"
}

resend_message_range() {
    TOPIC="$1"
    FROM="$2"
    NUM="$3"
    echo "Resending $NUM message(s) on topic: $TOPIC, from $FROM"
    read_message_range ${TOPIC} ${FROM} ${NUM} | rpk topic produce ${TOPIC} --allow-auto-topic-creation --format "%v{hex}" --key "Resent"
}

RUN_203551_NUMBER=00203551
RUN_203551_START_TIMESTAMP=1760682422346
RUN_203551_STOP_TIMESTAMP=1760685842491
RUN_203551_TIMESTAMP=1760682420346

RUN_203552_NUMBER=00203552
RUN_203552_START_TIMESTAMP=1760685846939
RUN_203552_STOP_TIMESTAMP=1760688772185
RUN_203552_TIMESTAMP=1760685840000

RUN_FILE=HIFI${RUN_203552_NUMBER}.nxs

run_repeat_with_ef() {
    MY_PIPELINE_NAME=$1;shift;
    set -a -u

    run_repeat_start $MY_PIPELINE_NAME

    EF_THRESHOLD=$1;shift;
    EF_DURATION=$1;shift;
    EF_COOLOFF=$1;shift;
    EF_CONSTANT_MULTIPLE="";

    run_repeat_end
}

run_repeat_start() {
    MY_PIPELINE_NAME=$1;shift;

    set -u
    teardown_pipeline "test"

    set_pipeline_local_variables $MY_PIPELINE_NAME $MY_PIPELINE_NAME "test"

    reset_pipeline
    rpk topic trim-prefix $DAT_EVENT_TOPIC --no-confirm -o end
    rpk topic trim-prefix $FRAME_EVENT_TOPIC --no-confirm -o end
    rpk group seek ${GROUP_EVENT_FORMATION} --to $RUN_203551_TIMESTAMP --topics $TRACE_TOPIC --allow-new-topics
}

run_repeat_end() {
    set -u

    deploy_pipeline "test"

    resend_message_range $CONTROL_TOPIC $RUN_203551_START_TIMESTAMP 1

    echo "Waiting until $NEXUS_LOCAL_HOST_PATH/$RUN_FILE is written"

    until [ -f "$NEXUS_LOCAL_HOST_PATH/$RUN_FILE" ]
    do
        sleep 5
    done

    resend_message_range $CONTROL_TOPIC $RUN_203551_STOP_TIMESTAMP 1

    echo "Waiting until $NEXUS_LOCAL_HOST_PATH/completed/$RUN_FILE is written"
    until [ -f "$NEXUS_LOCAL_HOST_PATH/completed/$RUN_FILE" ]
    do
        sleep 5
    done

    teardown_pipeline "test"
}

run_repeat_with_ef "test1" 5 1 0
#run_repeat_with_ef "test2" 10 1 0
#run_repeat_with_ef "test3" 25 1 0
#run_repeat_with_ef "test4" 50 1 0