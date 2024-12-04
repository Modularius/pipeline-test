g_APPLICATION_PREFIX="../supermusr-data-pipeline/target/release/"
#g_APPLICATION_PREFIX="cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "

g_RUN_SIMULATOR="${g_APPLICATION_PREFIX}run-simulator"
g_SIMULATOR="${g_APPLICATION_PREFIX}simulator"
g_TRACE_READER="${g_APPLICATION_PREFIX}trace-reader"
g_TRACE_TO_EVENTS="${g_APPLICATION_PREFIX}trace-to-events"
g_EVENT_AGGREGATOR="${g_APPLICATION_PREFIX}digitiser-aggregator"
g_NEXUS_WRITER="${g_APPLICATION_PREFIX}nexus-writer"

g_GROUP_WRITER=nexus-writer
g_GROUP_AGGREGATOR=digitiser-aggregator
g_GROUP_EVENT_FORMATION=trace-to-events

g_PROCESS_WRITER=nexus-writer
g_PROCESS_AGGREGATOR=digitiser-aggre
g_PROCESS_EVENT_FORMATION=trace-to-events

g_OTEL_ENDPOINT="--otel-endpoint http://localhost:4317/v1/traces"
#g_OTEL_ENDPOINT="--otel-endpoint http://172.16.113.245:4317/v1/traces"       # HiFi
#g_OTEL_ENDPOINT="--otel-endpoint http://146.199.207.182:4317/v1/traces"      # MyPC
#g_OTEL_ENDPOINT=""

g_PIPELINE_NAME="local"

g_OBSV_ADDRESS="127.0.0.1:2909"       # Local
#g_OBSV_ADDRESS="172.16.113.245:29090"       # Dev4

