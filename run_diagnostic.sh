## Setup Pipeline
. ./Settings/PipelineSetup.sh


### Enact Pipeline Configuration for Chosen Broker
#### Local
. ./Settings/Local/PipelineConfig.sh

# Diagnose Daq Traces
${APPLICATION_PREFIX}/diagnostics daq-trace --broker $BROKER --topic $TRACE_TOPIC  --group vis-3