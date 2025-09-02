#NEXUS_WRITER="$(nix build .#nexus-writer-container-image --no-link --print-out-paths)"
#AGGREGATOR="$(nix build .#digitiser-aggregator-container-image --no-link --print-out-paths)"
#EVENT_FORMATION="$(nix build .#trace-to-events-container-image --no-link --print-out-paths)"

docker load --input $(nix build .#nexus-writer-container-image --no-link --print-out-paths)
docker load --input $(nix build .#digitiser-aggregator-container-image --no-link --print-out-paths)
docker load --input $(nix build .#trace-to-events-container-image --no-link --print-out-paths)
docker load --input $(nix build .#simulator-container-image --no-link --print-out-paths)
docker load --input $(nix build .#trace-viewer-container-image --no-link --print-out-paths)

cd ../supermusr-data-pipeline
buildah bud -f Containerfile --build-arg component=trace-to-events -t supermusr-trace-to-events:latest
buildah bud -f Containerfile --build-arg component=digitiser-aggregator -t supermusr-digitiser-aggregator:latest
buildah bud -f Containerfile --build-arg component=nexus-writer -t supermusr-nexus-writer:latest
buildah bud -f Containerfile --build-arg component=simulator -t supermusr-simulator:latest
cd ../pipeline-test

buildah from  --name trace-to-events supermusr-trace-to-events
buildah from  --name digitiser-aggregator supermusr-digitiser-aggregator
buildah from  --name nexus-writer supermusr-nexus-writer
buildah from  --name simulator supermusr-simulator
