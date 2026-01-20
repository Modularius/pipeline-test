#### Pipeline

var pipeline = [
    &name="local"
    &consumer_groups=[
        &nexus_writer="nexus-writer"
        &digitiser_aggregator="digitiser-aggregator"
        &trace_to_events="trace-to-events"
    ]
]

#### Execution

var prefix = "../digital-muon-pipeline/target/release/"
#var prefix = "../digital-muon-pipeline/target/debug/"
#var prefix = "cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "

var execution_paths = [
    &simulator="${prefix}simulator"
    &trace_reader="${prefix}trace-reader"
    &nexus_writer="${prefix}nexus-writer"
    &digitiser_aggregator="${prefix}digitiser-aggregator"
    &trace_to_events="${prefix}trace-to-events"
]

var process_names = [
    &nexus_writer="nexus-writer"
    &digitiser_aggregator="digitiser-aggre"
    &trace_to_events="trace-to-events"
]

var container_images = [
    &nexus_writer="supermusr-nexus-writer:latest"
    &digitiser_aggregator="supermusr-digitiser-aggregator:latest"
    &trace_to_events="supermusr-trace-to-events:latest"
    &simulator="supermusr-simulator:latest"
]

#### Observability

#g_OTEL_ENDPOINT="http://${g_LOCALHOST}:4317/v1/traces"
var OTEL_ENDPOINT = "http://172.16.105.83:4317/v1/traces"          # OTel VM
#g_OTEL_ENDPOINT="http://172.16.113.245:4317/v1/traces"       # HiFi
#g_OTEL_ENDPOINT="http://146.199.207.182:4317/v1/traces"      # MyPC
#g_OTEL_ENDPOINT=""

var g_OBSV_ADDRESS_EVENT_FORMATION = "127.0.0.1:29090"       # Local
var g_OBSV_ADDRESS_AGGREGATOR = "127.0.0.1:29091"       # Local
var g_OBSV_ADDRESS_WRITER = "127.0.0.1:29092"       # Local
var g_OBSV_ADDRESS_SIM = "127.0.0.1:29093"       # Local
#g_OBSV_ADDRESS="172.16.113.245:29090"       # Dev4

## OpenTelemetry Observability Levels
#g_OTEL_LEVEL_EVENT_FORMATION="--otel-level=info"
#g_OTEL_LEVEL_AGGREGATOR="--otel-level=info"
#g_OTEL_LEVEL_WRITER="--otel-level=info"
#g_OTEL_LEVEL_SIM="--otel-level=info"

## Tell the logger not to use ansi colours (comment out to enable them)
set E:NO_COLOR = true

## Stdout Observability Levels
var RUST_LOG_OFF = tonic=off,h2=off,tokio_util=off,tower=off,hyper=off
set E:RUST_LOG = info,digitiser_aggregator=info,nexus_writer=info,trace_to_events=info,$RUST_LOG_OFF

## Otel Observability Levels
set E:OTEL_LEVEL = info,simulator=off,digitiser_aggregator=info,nexus_writer=info,trace_to_events=info,trace_to_events::channels=warn,trace_to_events::pulse_detection=warn

#### Event Formation
#g_TTE_INPUT_MODE="advanced-muon-detector --muon-onset=0.1 --muon-fall=-0.1 --muon-termination=0.01 --duration=10 --smoothing-window-size=10"
var trace-to-events-command = [
    &settings1=[
        &mode="differential-threshold-discriminator"
        &begin_threshold="--begin-threshold=5"
        &end_threshold="--end-threshold=0"
        &begin_duration="--begin-duration=2"
        &end_duration="--end-duration=0"
        &cooloff="--cool-off=0"
        &peak_mode="--peak-height-mode=value-at-end-trigger"
        &peak_basis="--peak-height-basis=trace-baseline"
    ]
]

#g_TTE_INPUT_COMMAND="${g_TTE_INPUT_MODE} ${g_TTE_THRESHOLD} ${g_TTE_DURATION} ${g_TTE_COOLOFF} ${g_TTE_PEAK_MODE} ${g_TTE_PEAK_BASIS}"

#### Brokers
fn generate_broker_settings {|LOCALHOST MAX_DIGITISER|
    echo [
        &local=[
            # Use This Broker
            &broker=$LOCALHOST":19092"

    # Broker Topics
            &topics=[
                &TRACE="Traces"
                &DAT_EVENT="Events"
                &FRAME_EVENT="FrameEvents"
                &CONTROL="Controls"
                &LOGS="Logs"
                &SELOGS="SELogs"
                &ALARMS="Alarms"
            ]
            # Trace Source Dependent Event Formation Settings
            &event_formation=[
                &POLARITY="positive"
                &BASELINE="0"
            ]
            # Digitisers Expected from Broker
            &DIGITISERS=-d(seq -s"," 0 $MAX_DIGITISER)
            &FRAME_TTL_MS="3500"
            # Output Path
            &paths=[
                NEXUS_OUTPUT="Output/local"
                NEXUS_ARCHIVE="archive/incoming/local"
            ]
            &RUN_TTL_MS=9000
        ]
    ]
}
