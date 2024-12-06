## Setup Pipeline
. ./Settings/PipelineSetup.sh


### Enact Pipeline Configuration for Chosen Broker
#### Local
. ./Settings/Local/PipelineConfig.sh

rpk group delete vis-3

# Diagnose Daq Traces
DIAGNOSTIC_PREFIX="../supermusr-data-pipeline/target/release/"
${DIAGNOSTIC_PREFIX}diagnostics daq-trace --broker $BROKER --topic $TRACE_TOPIC  --group vis-3