use ./../pipeline_control pc

var mode = [
    &run={|settings|
        # Trace To Events
        var commands = [
            "--broker="$settings[broker][broker]
            "--consumer-group="$settings[pipeline][consumer_groups][trace_to_events]
            "--observability-address 0.0.0.0"
            "--trace-topic="$settings[broker][topics][TRACE]
            "--event-topic="$settings[broker][topics][DAT_EVENT]
            "--baseline="$settings[broker][event_formation][BASELINE]
            "--otel-endpoint="$pc:OTEL_ENDPOINT
            "--otel-namespace="$settings[broker][name]
        ]
        $settings[process_names][trace_to_events] @commands
    }
]