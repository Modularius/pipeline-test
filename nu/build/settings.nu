const prefix = "../digital-muon-pipeline/target/release/"
#const prefix = "../digital-muon-pipeline/target/debug/"
#const prefix = "cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "

export const components = {
    trace_to_events: {
        execution_path: ($prefix ++ "trace-to-events"), process_name: "trace-to-events" container_image: "supermusr-trace-to-events:latest",
        image_env_vars: { image: "IMAGE_EVENT_FORMATION", obvs_port: "OBSV_ADDRESS_EVENT_FORMATION", args: "EVENT_FORMATION_ARGS" },
        observability: { obsv_address: "127.0.0.1:29090" tracing_level: "info", otel_level: "info,trace_to_events::channels=info,trace_to_events::pulse_detection=info" }
    },
    digitiser_aggregator: {
        execution_path: ($prefix ++ "digitiser-aggregator"), process_name: "digitiser-aggre" container_image: "supermusr-digitiser-aggregator:latest",
        image_env_vars: { image: "IMAGE_AGGREGATOR", obvs_port: "OBSV_ADDRESS_AGGREGATOR", args: "AGGREGATOR_ARGS" },
        observability: { obsv_address: "127.0.0.1:29091" tracing_level: "info", otel_level: "info" }
    },
    nexus_writer: {
        execution_path: ($prefix ++ "nexus-writer"), process_name: "nexus-writer" container_image: "supermusr-nexus-writer:latest",
        image_env_vars: { image: "IMAGE_WRITER", obvs_port: "OBSV_ADDRESS_WRITER", args: "WRITER_ARGS" },
        observability: { obsv_address: "127.0.0.1:29092" tracing_level: "info", otel_level: "info" }
    },
    simulator: {
        execution_path: ($prefix ++ "simulator"), process_name: "simulator" container_image: "supermusr-digital-simulator:latest",
        image_env_vars: { image: "IMAGE_SIMULATOR", obvs_port: "OBSV_ADDRESS_SIMULATOR", args: "SIMULATOR_ARGS" },
        observability: { obsv_address: "127.0.0.1:29093" tracing_level: "warn", otel_level: "warn" }
    },
    diagnostics: {
        execution_path: ($prefix ++ "diagnostics"), process_name: "diagnostics" container_image: "supermusr-diagnostics:latest",
        #image_env_vars: { image: "IMAGE_DIAGNOSTICS", obvs_port: "OBSV_ADDRESS_DIAGNOSTICS", args: "DIAGNOSTICS_ARGS" },
        #observability: { obsv_address: "127.0.0.1:29094" tracing_level: "info", otel_level: "info" }
    }
}

export const constants = {
    no_color_env: true,
    rust_log: "info",
    otel_level: "info",
    otel_endpoint: "http://172.16.105.83:4317/v1/traces",
}

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

#### Event Formation
const detector_settings = {
    threshold_1: [ "fixed-threshold-discriminator"
        "--threshold", "2100",
        "--duration", "1",
        "--cool-off", "0"
    ],
    differential_1: [ "differential-threshold-discriminator",
        "--begin-threshold", "5",
        "--end-threshold", "0",
        "--begin-duration", "2",
        "--end-duration", "0",
        "--cool-off", "0"
        "--peak-height-mode", "value-at-end-trigger",
        "--peak-height-basis", "trace-baseline"
    ],
    smoothing_1: [ "smoothing-detector",
        "--noise-centile", "90",
        "--kernel-sigma", "4",
        "--nsig-noise", "5" #,
        #"--min-size", "2"
    ]
}

const pipeline_settings = {
    pipeline_1: {
        trace_to_events: {
            send_eventlist_buffer_size: 1024,
        },
        digitiser_aggregator: {
            frame_ttl_ms: 200,
            send_frame_buffer_size: 64
        }
        nexus_writer: {
            paths: {
                nexus_output: "Output",
                nexus_archive: "archive/incoming"
            },
            run_ttl_ms: 15000
        }
    }
}

#### Brokers
const brokers = {
    local: {
        pipeline_name: "hifi",
        address: "localhost:9092",
        topics:             { trace: "daq-traces-in", dat_event: "daq-events", frame_event: "frame-events", control: "ics-control-change", logs: "Logsics-metadata", selogs: "SELogsHIFI_sampleEnv", alarms: "ics-alarms" },
        consumer_groups:    { trace_to_events: "trace_to_events", digitiser_aggregator: "digitiser_aggregator", nexus_writer: "nexus_writer", diagnostics: "diagnostics" },
        # Trace Source Dependent Event Formation Settings
        trace_to_events: {
            polarity: "positive",
            baseline: 0
        },
        digitiser_aggregator: {
            digitiser_ids: [4,5,6,7,8,9,10,11]
        },
        nexus_writer: {
            subdirectory: "hifi",
        }
    },
    musr_to_local: {
        pipeline_name: "musr",
        address: "localhost:9092",
        topics:             { trace: "musr-daq-traces-in", dat_event: "musr-daq-events", frame_event: "musr-frame-events", control: "ics-control-change", logs: "Logsics-metadata", selogs: "SELogsHIFI_sampleEnv", alarms: "ics-alarms" },
        consumer_groups:    { trace_to_events: "musr_trace_to_events", digitiser_aggregator: "musr_digitiser_aggregator", nexus_writer: "musr_nexus_writer", diagnostics: "diagnostics" },
        # Trace Source Dependent Event Formation Settings
        trace_to_events: {
            polarity: "positive",
            baseline: 0
        },
        digitiser_aggregator: {
            digitiser_ids: [4,5,6,7,8,9,10,11]
        },
        nexus_writer: {
            subdirectory: "hifi_musr",
        }
    }
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
            "OTEL_LEVEL": (build_otel_level_env),
        }
    }
}

