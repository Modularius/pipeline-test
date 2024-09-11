#RUN_SIMULATOR="cargo run --release --bin run-simulator --"
RUN_SIMULATOR="../supermusr-data-pipeline/target/release/run-simulator"

#TRACE_TO_EVENTS="cargo run --release --bin trace-to-events --"
#EVENT_AGGREGATOR="cargo run --release --bin digitiser-aggregator --"
#NEXUS_WRITER="cargo run --release --bin nexus-writer --"

TRACE_TO_EVENTS="../supermusr-data-pipeline/target/release/trace-to-events"
NEXUS_WRITER="../supermusr-data-pipeline/target/release/nexus-writer"
EVENT_AGGREGATOR="../supermusr-data-pipeline/target/release/digitiser-aggregator"

#SIMULATOR="cargo run --release --bin simulator --"
#TRACE_READER="cargo run --release --bin trace-reader --"

SIMULATOR="../supermusr-data-pipeline/target/release/simulator"
TRACE_READER="../supermusr-data-pipeline/target/release/trace-reader"
