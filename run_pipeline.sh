## Include Library Scripts
. ./Libs/lib.sh
. ./Libs/lib_pipeline.sh

## Setup Pipeline
. ./Settings/PipelineSetup.sh

### Enact Event Formation Configuration
. ./Settings/EventFormationConfig.sh

### Enact Pipeline Configuration for Chosen Broker
#### Local
g_MAX_DIGITISER=7
. ./Settings/Local/PipelineConfig.sh
#### HiFi
#. ./Settings/HiFi/PipelineConfig.sh

## OpenTelemetry Observability Levels
g_OTEL_LEVEL_EVENT_FORMATION="--otel-level=info"
g_OTEL_LEVEL_AGGREGATOR="--otel-level=info"
g_OTEL_LEVEL_WRITER="--otel-level=info"
g_OTEL_LEVEL_SIM="--otel-level=info"

## Stdout Observability Levels
export RUST_LOG=info,digitiser_aggregator=warn,nexus_writer=info,trace_to_events=off,$g_RUST_LOG_OFF

echo "Current Time: $(date +"%T")"

## Main Script

#### Local
. ./Scripts/local_no_docker.sh
#### HiFi
#. ./Scripts/hifi.sh