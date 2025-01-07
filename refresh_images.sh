NEXUS_WRITER="$(nix build .#nexus-writer-container-image --no-link --print-out-paths)"
AGGREGATOR="$(nix build .#digitiser-aggregator-container-image --no-link --print-out-paths)"
EVENT_FORMATION="$(nix build .#trace-to-events-container-image --no-link --print-out-paths)"

podman load --input $(nix build .#nexus-writer-container-image --no-link --print-out-paths)
podman load --input $(nix build .#digitiser-aggregator-container-image --no-link --print-out-paths)
podman load --input $(nix build .#trace-to-events-container-image --no-link --print-out-paths)