## Include Library Scripts
. ./Libs/lib.sh

## Setup Pipeline
. ./Settings/PipelineSetup.sh

### Enact Event Formation Configuration
. ./Settings/EventFormationConfig.sh

### Enact Pipeline Configuration for Chosen Broker
. ./Settings/Local/PipelineConfig.sh

## OpenTelemetry Observability Levels
g_OTEL_LEVEL_EVENT_FORMATION="--otel-level=off"
g_OTEL_LEVEL_AGGREGATOR="--otel-level=off"
g_OTEL_LEVEL_WRITER="--otel-level=off"
g_OTEL_LEVEL_SIM="--otel-level=off"

## Stdout Observability Levels
export RUST_LOG=info,digitiser_aggregator=off,nexus_writer=off,trace_to_events=off,$g_RUST_LOG_OFF

## Main Script

# run_persistant_components

# sleep 1

# run_trace_simulator