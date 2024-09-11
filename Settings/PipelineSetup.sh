BROKER="130.246.55.29:9092"

#RUN_SIMULATOR="cargo run --release --bin run-simulator --"
RUN_SIMULATOR="../supermusr-data-pipeline/target/release/run-simulator"

#SIMULATOR="cargo run --release --bin simulator --"
SIMULATOR="../supermusr-data-pipeline/target/release/simulator"

#TRACE_READER="cargo run --release --bin trace-reader --"
TRACE_READER="../supermusr-data-pipeline/target/release/trace-reader"

#TRACE_TO_EVENTS="cargo run --release --bin trace-to-events --"
TRACE_TO_EVENTS="../supermusr-data-pipeline/target/release/trace-to-events"
#EVENT_AGGREGATOR="cargo run --release --bin digitiser-aggregator --"
EVENT_AGGREGATOR="../supermusr-data-pipeline/target/release/digitiser-aggregator"
#NEXUS_WRITER="cargo run --release --bin nexus-writer --"
NEXUS_WRITER="../supermusr-data-pipeline/target/release/nexus-writer"


GROUP_WRITER=nexus-writer
GROUP_AGGREGATOR=digitiser-aggregator
GROUP_EVENT_FORMATION=trace-to-events

PROCESS_WRITER=nexus-writer
PROCESS_AGGREGATOR=digitiser-aggre
PROCESS_EVENT_FORMATION=trace-to-events

OTEL_ENDPOINT="http://localhost:4317/v1/traces"
#OTEL_ENDPOINT="http://146.199.207.182:4317/v1/traces"
