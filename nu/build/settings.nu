const prefix = "../digital-muon-pipeline/target/release/"
#const prefix = "../digital-muon-pipeline/target/debug/"
#const prefix = "cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "

export const components = {
    trace_to_events: {
        execution_path: ($prefix ++ "trace-to-events"), process_name: "trace-to-events" container_image: "supermusr-nexus-writer:latest",
        image_env_vars: { image: "IMAGE_EVENT_FORMATION", obvs_port: "OBSV_ADDRESS_EVENT_FORMATION", args: "EVENT_FORMATION_ARGS" },
        observability: { obsv_address: "127.0.0.1:29090" tracing_level: "info", otel_level: "info,trace_to_events::channels=info,trace_to_events::pulse_detection=warn" }
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
        execution_path: ($prefix ++ "simulator"), process_name: "simulator" container_image: "supermusr-simulator:latest",
        image_env_vars: { image: "IMAGE_SIMULATOR", obvs_port: "OBSV_ADDRESS_SIMULATOR", args: "SIMULATOR_ARGS" },
        observability: { obsv_address: "127.0.0.1:29093" tracing_level: "info", otel_level: "info" }
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
    theshold_1: [ "fixed-threshold-discriminator"
        "--threshold", "25",
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
    ]
}

const pipeline_settings = {
    pipeline_1: {
        trace_to_events: {
            send_eventlist_buffer_size: 1024,
        },
        digitiser_aggregator: {
            frame_ttl_ms: 3500,
            send_frame_buffer_size: 64
        }
        nexus_writer: {
            paths: {
                nexus_output: "Output",
                nexus_archive: "archive/incoming"
            },
            run_ttl_ms: 9000
        }
    }
}

#### Brokers
const brokers = {
    local: {
        pipeline_name: "local",
        address: "localhost:19092",
        topics:             { trace: "Traces", dat_event: "Events", frame_event: "FrameEvents", control: "Controls", logs: "Logs", selogs: "SELogs", alarms: "Alarms" },
        consumer_groups:    { trace_to_events: "trace_to_events", digitiser_aggregator: "digitiser_aggregator", nexus_writer: "nexus_writer", diagnostics: "diagnostics" },
        # Trace Source Dependent Event Formation Settings
        trace_to_events: {
            polarity: "positive",
            baseline: 0
        },
        digitiser_aggregator: {
            digitiser_ids: [0,1,2,3,4,5,6,7]
        },
        nexus_writer: {
            subdirectory: "local",
        }
    },
    superlocal: {
        pipeline_name: "local",
        address: "localhost:19092",
        topics:             { trace: "Traces", dat_event: "Events", frame_event: "FrameEvents", control: "Controls", logs: "Logs", selogs: "SELogs", alarms: "Alarms" },
        consumer_groups:    { trace_to_events: "trace_to_events", digitiser_aggregator: "digitiser_aggregator", nexus_writer: "nexus_writer", diagnostics: "diagnostics" },
        # Trace Source Dependent Event Formation Settings
        trace_to_events: {
            polarity: "positive",
            baseline: 0
        },
        digitiser_aggregator: {
            digitiser_ids: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119]
        },
        nexus_writer: {
            subdirectory: "local",
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

