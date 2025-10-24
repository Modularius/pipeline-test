## Setup Pipeline
. ./Settings/Local/Broker.sh
. ./Settings/Pipeline.sh

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
    read_message_range ${TOPIC} ${FROM} ${NUM} | rpk topic produce ${TOPIC} --allow-auto-topic-creation --format "%v{hex}" --key "Resent"
}

RUN_NUMBER=00203551
RUN_FILE=HIFI${RUN_NUMBER}.nxs
RUN_PATH=Output/Local_test/
TIMESTAMP=1760682420346
RUN_START_TIMESTAMP=1760682422346
RUN_STOP_TIMESTAMP=1760685842491

resend_message_range ics-control-change $RUN_START_TIMESTAMP 1
rpk group seek ${g_GROUP_EVENT_FORMATION} --to $TIMESTAMP --topics $g_TRACE_TOPIC --allow-new-topics

rm Output/Local_test/*.nxs
rm Output/Local_test/Complete/*.nxs

. ./run_pipeline.sh

until [ -f "$RUN_PATH/$RUN_FILE" ]
do
    sleep 1
done

resend_message_range ics-control-change $RUN_STOP_TIMESTAMP 1

until [ -f "$RUN_PATH/complete/$RUN_FILE" ]
do
    sleep 1
done

. ./destroy_pipeline.sh

h5diff -c Output/Local_test/completed/$RUN_FILE archive/incoming/hifi_1/$RUN_FILE