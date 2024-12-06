## Include Library Scripts
. ./Libs/lib.sh

## Setup Pipeline
. ./Settings/PipelineSetup.sh

### Enact Event Formation Configuration
. ./Settings/EventFormationConfig.sh

### Enact Pipeline Configuration for Chosen Broker
. ./Settings/Local/PipelineConfig.sh

## OpenTelemetry Observability Levels
export OTEL_BSP_MAX_QUEUE_SIZE=8192
export OTEL_LEVEL_EVENT_FORMATION="--otel-level=info"
export OTEL_LEVEL_AGGREGATOR="--otel-level=info"
export OTEL_LEVEL_WRITER="--otel-level=info"
export OTEL_LEVEL_SIM="--otel-level=off"

## Stdout Observability Levels
export RUST_LOG=off,digitiser_aggregator=warn,nexus_writer=error,trace_to_events=warn,$RUST_LOG_OFF

## Main Script

./Scripts/multiple_pipelines.sh

#sleep 1

#./Scripts/RunSimulator.sh
#./Scripts/SimultateRuns.sh