use ../../settings.nu [components, constants, brokers, pipeline_settings, detector_settings]
export const SETTINGS_PATH = "compiled.settings.json"

const RUST_LOG_OFF = "tonic=off,h2=off,tokio_util=off,tower=off,hyper=off"
export def build_rust_log_env [] : nothing -> string {
    [$constants.rust_log,
        $"trace_to_events=($components.trace_to_events.observability.tracing_level)",
        $"digitiser_aggregator=($components.digitiser_aggregator.observability.tracing_level)",
        $"nexus_writer=($components.nexus_writer.observability.tracing_level)",
        $"simulator=($components.simulator.observability.tracing_level)",
        $RUST_LOG_OFF
    ] | str join ','
}

export def build_otel_level_env [] : nothing -> string {
    [$constants.otel_level,
        $"trace_to_events=($components.trace_to_events.observability.otel_level)",
        $"digitiser_aggregator=($components.digitiser_aggregator.observability.otel_level)",
        $"nexus_writer=($components.nexus_writer.observability.otel_level)",
        $"simulator=($components.simulator.observability.otel_level)"
    ] | str join ','
}

export def "build_settings" [broker: string, pipeline: string, detector: string] : nothing -> record {
    let broker = $brokers | (get $broker)
    let pipeline = $pipeline_settings | (get $pipeline)
    let detector = $detector_settings | (get $detector)
    {
        constants: $constants,
        components: $components,
        broker: $broker,
        pipeline: $pipeline,
        detector: $detector,
        global_env_vars: {
            "NO_COLOR": ($constants.no_color_env | into string),
            "RUST_LOG": (build_rust_log_env),
            "OTEL_LEVEL": (build_otel_level_env) #,
            #"OTEL_BSP_MAX_QUEUE_SIZE": "16384",
            #"OTEL_BSP_MAX_EXPORT_BATCH_SIZE": "8192"
        }
    }
}

