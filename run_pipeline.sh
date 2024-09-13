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
OTEL_LEVEL_EVENT_FORMATION="--otel-level=off"
OTEL_LEVEL_AGGREGATOR="--otel-level=off"
OTEL_LEVEL_WRITER="--otel-level=off"
OTEL_LEVEL_SIM="--otel-level=off"

## Stdout Observability Levels
export RUST_LOG=info,digitiser_aggregator=off,nexus_writer=off,trace_to_events=off,$RUST_LOG_OFF

## Main Script

#### Local
. ./Scripts/local_no_docker.sh
#### HiFi
#. ./Scripts/HiFi.sh