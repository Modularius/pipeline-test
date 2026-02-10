g_APPLICATION_PREFIX="../supermusr-data-pipeline/target/release/"
#g_APPLICATION_PREFIX="cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "

g_RUN_SIMULATOR="${g_APPLICATION_PREFIX}run-simulator"
g_SIMULATOR="${g_APPLICATION_PREFIX}simulator"
g_TRACE_READER="${g_APPLICATION_PREFIX}trace-reader"
g_TRACE_TO_EVENTS="${g_APPLICATION_PREFIX}trace-to-events"
g_EVENT_AGGREGATOR="${g_APPLICATION_PREFIX}digitiser-aggregator"
g_NEXUS_WRITER="${g_APPLICATION_PREFIX}nexus-writer"

g_PROCESS_WRITER=nexus-writer
g_PROCESS_AGGREGATOR=digitiser-aggre
g_PROCESS_EVENT_FORMATION=trace-to-events