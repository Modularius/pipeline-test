set -a

g_OTEL_ENDPOINT="--otel-endpoint http://localhost:4317/v1/traces"
#g_OTEL_ENDPOINT="--otel-endpoint http://172.16.113.245:4317/v1/traces"       # HiFi
#g_OTEL_ENDPOINT="--otel-endpoint http://146.199.207.182:4317/v1/traces"      # MyPC
#g_OTEL_ENDPOINT=""

g_OBSV_ADDRESS_EVENT_FORMATION="127.0.0.1:29090"       # Local
g_OBSV_ADDRESS_AGGREGATOR="127.0.0.1:29091"       # Local
g_OBSV_ADDRESS_WRITER="127.0.0.1:29092"       # Local
g_OBSV_ADDRESS_SIM="127.0.0.1:29093"       # Local
#g_OBSV_ADDRESS="172.16.113.245:29090"       # Dev4

## OpenTelemetry Observability Levels
g_OTEL_LEVEL_EVENT_FORMATION="--otel-level=info"
g_OTEL_LEVEL_AGGREGATOR="--otel-level=info"
g_OTEL_LEVEL_WRITER="--otel-level=info"
g_OTEL_LEVEL_SIM="--otel-level=info"

## Stdout Observability Levels
g_RUST_LOG=info,digitiser_aggregator=info,nexus_writer=info,trace_to_events=off,$g_RUST_LOG_OFF

