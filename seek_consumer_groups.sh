## Setup Pipeline
. ./Settings/Local/Broker.sh
. ./Settings/Pipeline.sh

echo "Seeking new offsets for consumer groups: ${g_GROUP_EVENT_FORMATION}, ${g_GROUP_AGGREGATOR}, and ${g_GROUP_WRITER}"

#CTRL_TIMESTAMP=1760678999378 # Run 203550
CTRL_TIMESTAMP=1760682422346 # Run 203551
TIMESTAMP=1760682420346
rpk group seek ${g_GROUP_EVENT_FORMATION} --to $TIMESTAMP --topics $g_TRACE_TOPIC --allow-new-topics
rpk group seek ${g_GROUP_AGGREGATOR} --to end --topics $g_DAT_EVENT_TOPIC --allow-new-topics
rpk group seek ${g_GROUP_WRITER} --to end --topics $g_FRAME_EVENT_TOPIC
rpk group seek ${g_GROUP_WRITER} --to $CTRL_TIMESTAMP --topics $g_CONTROL_TOPIC --allow-new-topics
rpk group seek ${g_GROUP_WRITER} --to $TIMESTAMP --topics $g_SELOGS_TOPIC --topics $g_LOGS_TOPIC --allow-new-topics
