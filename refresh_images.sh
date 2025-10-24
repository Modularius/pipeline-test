podman load --input $(nix build .#trace-to-events-container-image --no-link --print-out-paths)
podman load --input $(nix build .#digitiser-aggregator-container-image --no-link --print-out-paths)
podman load --input $(nix build .#nexus-writer-container-image --no-link --print-out-paths)

cd ../supermusr-data-pipeline
buildah bud -f Containerfile --build-arg component=trace-to-events -t supermusr-trace-to-events:latest
buildah bud -f Containerfile --build-arg component=digitiser-aggregator -t supermusr-digitiser-aggregator:latest
buildah bud -f Containerfile --build-arg component=nexus-writer -t supermusr-nexus-writer:latest
buildah bud -f Containerfile --build-arg component=simulator -t supermusr-simulator:latest
cd ../pipeline-test

cd ../supermusr-data-pipeline
buildah bud -f trace-viewer/Containerfile -t supermusr-trace-viewer:latest --layers=true
cd ../pipeline-test
