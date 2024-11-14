## Include Library Scripts
. ./Libs/lib.sh

## Setup Pipeline
. ./Settings/PipelineSetup.sh

### Enact Event Formation Configuration
. ./Settings/EventFormationConfig.sh

### Enact Pipeline Configuration for Chosen Broker
#### Local
MAX_DIGITISER=7 . ./Settings/Local/PipelineConfig.sh
#### HiFi
#. ./Settings/HiFi/PipelineConfig.sh

## OpenTelemetry Observability Levels
OTEL_LEVEL_EVENT_FORMATION="--otel-level=info"
OTEL_LEVEL_AGGREGATOR="--otel-level=info"
OTEL_LEVEL_WRITER="--otel-level=info"
OTEL_LEVEL_SIM="--otel-level=info"

## Stdout Observability Levels
export RUST_LOG=info,digitiser_aggregator=warn,nexus_writer=info,trace_to_events=off,$RUST_LOG_OFF

echo "Current Time: $(date +"%T")"

## Main Script

#### Local
. ./Scripts/local_no_docker.sh
#### HiFi
#. ./Scripts/hifi.sh