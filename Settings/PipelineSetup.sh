### For running bare metal as release
#APPLICATION_PREFIX="../supermusr-data-pipeline/target/release/"
#APPLICATION_SUFFIX=""
#NEXUS_WRITER_PREFIX=${APPLICATION_PREFIX}

### For running bare metal from cargo
#APPLICATION_PREFIX="cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "
#APPLICATION_SUFFIX=""
#NEXUS_WRITER_PREFIX=${APPLICATION_PREFIX}

## For running from podman
COMMAND_PREFIX="podman run --rm -d --memory 15g --restart on-failure"
IMAGE_PREFIX=ghcr.io/stfc-icd-research-and-design/supermusr-
APPLICATION_PREFIX="$COMMAND_PREFIX $IMAGE_PREFIX"
APPLICATION_SUFFIX=":main"
FORMATION_PREFIX="$COMMAND_PREFIX --name=event_formation $IMAGE_PREFIX"
AGGREGATOR_PREFIX="$COMMAND_PREFIX --name=digitiser_aggregator $IMAGE_PREFIX"
NEXUS_WRITER_PREFIX="$COMMAND_PREFIX -v $ARCHIVE_MOUNT:/archive -v $LOCAL_MOUNT:/local --name=nexus_writer $IMAGE_PREFIX"

RUN_SIMULATOR="${APPLICATION_PREFIX}run-simulator${APPLICATION_SUFFIX}"
SIMULATOR="${APPLICATION_PREFIX}simulator${APPLICATION_SUFFIX}"
TRACE_READER="${APPLICATION_PREFIX}trace-reader${APPLICATION_SUFFIX}"
TRACE_TO_EVENTS="${FORMATION_PREFIX}trace-to-events${APPLICATION_SUFFIX}"
EVENT_AGGREGATOR="${AGGREGATOR_PREFIX}digitiser-aggregator${APPLICATION_SUFFIX}"
EVENT_AGGREGATOR="../supermusr-data-pipeline/target/release/digitiser-aggregator"
NEXUS_WRITER="${NEXUS_WRITER_PREFIX}nexus-writer${APPLICATION_SUFFIX}"

GROUP_WRITER=nexus-writer
GROUP_AGGREGATOR=digitiser-aggregator
GROUP_EVENT_FORMATION=trace-to-events

PROCESS_WRITER=nexus-writer
PROCESS_AGGREGATOR=digitiser-aggre
PROCESS_EVENT_FORMATION=trace-to-events

FRAME_TTL_MS=2000
FRAME_BUFFER_SIZE=10000
RUN_TTL_MS=10000

#OTEL_ENDPOINT="--otel-endpoint http://localhost:4317/v1/traces"            # Local
OTEL_ENDPOINT="--otel-endpoint http://172.16.113.245:4317/v1/traces"       # Dev4
#OTEL_ENDPOINT="--otel-endpoint http://146.199.207.182:4317/v1/traces"      # MyPC
#OTEL_ENDPOINT=""

OBSV_ADDRESS="127.0.0.1:2909"       # Local
#OBSV_ADDRESS="172.16.113.245:29090"       # Dev4

RUST_LOG_OFF=tonic=off,h2=off,tokio_util=off,tower=off,hyper=off
RUST_LOG=off,digitiser_aggregator=warn,nexus_writer=error,trace_to_events=warn,$RUST_LOG_OFF