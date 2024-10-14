APPLICATION_PREFIX="../supermusr-data-pipeline/target/release/"
#APPLICATION_PREFIX="cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "

RUN_SIMULATOR="${APPLICATION_PREFIX}run-simulator"
SIMULATOR="${APPLICATION_PREFIX}simulator"
TRACE_READER="${APPLICATION_PREFIX}trace-reader"
TRACE_TO_EVENTS="${APPLICATION_PREFIX}trace-to-events"
EVENT_AGGREGATOR="${APPLICATION_PREFIX}digitiser-aggregator"
NEXUS_WRITER="${APPLICATION_PREFIX}/nexus-writer"


GROUP_WRITER=nexus-writer
GROUP_AGGREGATOR=digitiser-aggregator
GROUP_EVENT_FORMATION=trace-to-events

PROCESS_WRITER=nexus-writer
PROCESS_AGGREGATOR=digitiser-aggre
PROCESS_EVENT_FORMATION=trace-to-events

#OTEL_ENDPOINT="--otel-endpoint http://localhost:4317/v1/traces"
#OTEL_ENDPOINT="--otel-endpoint http://172.16.113.245:4317/v1/traces"       # HiFi
#OTEL_ENDPOINT="--otel-endpoint http://146.199.207.182:4317/v1/traces"      # MyPC
OTEL_ENDPOINT=""
