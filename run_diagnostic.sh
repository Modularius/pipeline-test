## Setup Pipeline
. ./Settings/Execution.sh


### Enact Pipeline Configuration for Chosen Broker
#### Local
#. ./Settings/Local/PipelineConfig.sh
#### HiFi
#. ./Settings/HiFi/PipelineConfig.sh

# Use This Broker
#g_BROKER="130.246.55.29:9092"
g_BROKER="130.246.53.247:9092"

# Broker Topics
g_TRACE_TOPIC=traces-in
g_DAT_EVENT_TOPIC=daq-events
g_FRAME_EVENT_TOPIC=frame-events
g_CONTROL_TOPIC=ics-control-change
g_LOGS_TOPIC=ics-metadata
g_SELOGS_TOPIC=HIFI_sampleEnv
g_ALARMS_TOPIC=ics-alarms


# Diagnose Daq Traces
${g_APPLICATION_PREFIX}/diagnostics daq-trace --broker $g_BROKER --topic $g_TRACE_TOPIC  --group vis-3