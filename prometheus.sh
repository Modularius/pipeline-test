
PID_PROMETHEUS=$(sudo podman container ls --all --quiet --no-trunc --filter "name=prometheus")
sudo podman rm -f $PID_PROMETHEUS

sudo podman run -d --rm \
    -p 9090:9090 \
    -v ./Settings/prometheus.yml:/etc/prometheus/prometheus.yml \
    --name="prometheus"\
    --network="podman" \
    docker.io/prom/prometheus:v2.37.9