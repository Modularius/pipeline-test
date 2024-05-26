NEXUS_WRITER="$(nix build .#nexus-writer-container-image --no-link --print-out-paths ../supermusr-data-pipeline/)"
AGGREGATOR="$(nix build .#digitiser-aggregator-container-image --no-link --print-out-paths ../supermusr-data-pipeline/)"
EVENT_FORMATION="$(nix build .#trace-to-events-container-image --no-link --print-out-paths ../supermusr-data-pipeline/)"

docker load --input $NEXUS_WRITER
docker load --input $AGGREGATOR
docker load --input $EVENT_FORMATION