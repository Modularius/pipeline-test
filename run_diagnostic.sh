## Setup Pipeline
. ./Settings/PipelineSetup.sh


### Enact Pipeline Configuration for Chosen Broker
#### Local
. ./Settings/Local/PipelineConfig.sh
#### HiFi
#. ./Settings/HiFi/PipelineConfig.sh

# Diagnose Daq Traces
${g_APPLICATION_PREFIX}/diagnostics daq-trace --broker $g_BROKER --topic $g_TRACE_TOPIC  --group vis-3