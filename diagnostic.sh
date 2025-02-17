### Enact Pipeline Configuration for Chosen Broker
#### Local
. ./Settings/Local/Broker.sh

rpk group delete vis-3

# Diagnose Daq Traces
DIAGNOSTIC_PREFIX="../supermusr-data-pipeline/target/release/"
${DIAGNOSTIC_PREFIX}diagnostics daq-trace --broker $g_BROKER --topic $g_TRACE_TOPIC  --group vis-3