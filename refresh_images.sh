podman load --input $(nix build .#trace-to-events-container-image --no-link --print-out-paths)
podman load --input $(nix build .#digitiser-aggregator-container-image --no-link --print-out-paths)
podman load --input $(nix build .#nexus-writer-container-image --no-link --print-out-paths)