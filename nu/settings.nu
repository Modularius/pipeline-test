#### Execution

const prefix = "../digital-muon-pipeline/target/release/"
#var prefix = "../digital-muon-pipeline/target/debug/"
#var prefix = "cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "
const components = {
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
    }
}

const RUST_LOG_OFF = "tonic=off,h2=off,tokio_util=off,tower=off,hyper=off"
export def build_rust_log_env [overall: string, components: record] : nothing -> string {
    [$overall,
        $"trace_to_events=($components.trace_to_events.observability.tracing_level)",
        $"digitiser_aggregator=($components.digitiser_aggregator.observability.tracing_level)",
        $"nexus_writer=($components.nexus_writer.observability.tracing_level)",
        $"simulator=($components.simulator.observability.tracing_level)",
        $RUST_LOG_OFF
    ] | str join ','
}

export def build_otel_level_env [overall: string, components: record] : nothing -> string {
    [$overall,
        $"trace_to_events=($components.trace_to_events.observability.otel_level)",
        $"digitiser_aggregator=($components.digitiser_aggregator.observability.otel_level)",
        $"nexus_writer=($components.nexus_writer.observability.otel_level)",
        $"simulator=($components.simulator.observability.otel_level)"
    ] | str join ','
}

#### Observability

const constants = {
    no_color_env: true,
    otel_endpoint: "http://172.16.105.83:4317/v1/traces",
    components: $components,
}
#g_OTEL_ENDPOINT="http://${g_LOCALHOST}:4317/v1/traces"
#g_OTEL_ENDPOINT="http://172.16.113.245:4317/v1/traces"       # HiFi
#g_OTEL_ENDPOINT="http://146.199.207.182:4317/v1/traces"      # MyPC
#g_OTEL_ENDPOINT=""

def "build differential_threshold_discriminator" [begin_threshold: int, end_threshold: int, begin_duration: int, end_duration: int, cooloff: int, peak_mode: string, peak_basis: string] : nothing -> list<string> {
    [ "differential-threshold-discriminator",
        "--begin-threshold", ($begin_threshold | into string),
        "--end-threshold", ($end_threshold | into string),
        "--begin-duration", ($begin_duration | into string),
        "--end-duration", ($end_duration | into string),
        "--cooloff", ($cooloff | into string),
        "--peak_mode", $peak_mode,
        "--peak_basis", $peak_basis
    ]
}

#### Event Formation
const detector_settings = {
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
        digitiser_aggregator: {
            frame_ttl_ms: 3500,
            send_frame_buffer_size: 4000
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
        consumer_groups:    { trace_to_events: "trace_to_events", digitiser_aggregator: "digitiser_aggregator", nexus_writer: "nexus_writer" },
        # Trace Source Dependent Event Formation Settings
        trace_to_events: {
            polarity: "positive",
            baseline: 0
        },
        digitiser_aggregator: {
            digitiser_ids: [0,1,2,3,4,5,6,7] # Digitisers Expected from Broker
        },
        nexus_writer: {
            subdirectory: "local",
        }
    }
}

export def "build settings" [broker: string, pipeline: string, detector: string] : nothing -> record {
    $brokers | describe
    
    let broker = $brokers | (get $broker)
    let pipeline = $pipeline_settings | (get $pipeline)
    let detector = $detector_settings | (get $detector)
    {
        constants: $constants,
        broker: $broker,
        pipeline: $pipeline,
        detector: $detector,
    }
}

export def "build args simulator" [settings: record, instance_settings: record, source: string] : nothing -> list<string> {
    # Namespace
    let namespace = if $instance_settings.new_namespace? == null {
        $settings.broker.pipeline_name
    } else {
        $instance_settings.new_namespace
    }

    ["--broker", $settings.broker.address,
    "--otel-endpoint", $constants.otel_endpoint,
    "--otel-namespace", $namespace,
    "defined", $source,
    "--digitiser-trace-topic", $settings.broker.topics.trace,
    "--digitiser-event-topic", $settings.broker.topics.dat_event,
    "--frame-event-topic", $settings.broker.topics.frame_event,
    "--control-topic", $settings.broker.topics.control,
    "--runlog-topic", $settings.broker.topics.logs,
    "--selog-topic", $settings.broker.topics.selogs,
    "--alarm-topic", $settings.broker.topics.alarms]
}

export def "build args trace_to_events" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.trace_to_events
    let constant_component = $settings.constants.components.trace_to_events
    
    let topics = $settings.broker.topics

    # Namespace
    let namespace = if $instance_settings.new_namespace? == null {
        $settings.broker.pipeline_name
    } else {
        $instance_settings.new_namespace
    }

    [
        "--broker", $settings.broker.address,
        "--consumer-group", $settings.broker.consumer_groups.trace_to_events,
        "--observability-address", $constant_component.observability.obsv_address,
        "--trace-topic", $topics.trace,
        "--event-topic", $topics.dat_event,
        "--polarity", $broker_component.polarity,
        "--baseline", ($broker_component.baseline | into string),
        "--otel-endpoint", $settings.constants.otel_endpoint,
        "--otel-namespace", $namespace
    ] | append $settings.detector
}

export def "build args digitiser_aggregator" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.digitiser_aggregator
    let pipeline_component = $settings.pipeline.digitiser_aggregator
    let constant_component = $settings.constants.components.digitiser_aggregator

    let topics = $settings.broker.topics
    
    # Namespace
    let namespace = if $instance_settings.new_namespace? == null {
        $settings.broker.pipeline_name
    } else {
        $instance_settings.new_namespace
    }

    let digitiser_ids = $settings.broker.digitiser_aggregator.digitiser_ids | each {into string} | str join ','

    [
        "--broker", $settings.broker.address,
        "--group", $settings.broker.consumer_groups.digitiser_aggregator,
        "--observability-address", $constant_component.observability.obsv_address,
        "--input-topic", $topics.dat_event,
        "--output-topic", $topics.frame_event,
        "--frame-ttl-ms", ($pipeline_component.frame_ttl_ms | into string),
        "--send-frame-buffer-size", ($pipeline_component.send_frame_buffer_size | into string),
        "--otel-endpoint", $settings.constants.otel_endpoint,
        "--otel-namespace", $namespace,
        ("-d" ++ $digitiser_ids)
    ]
}

export def "build args nexus_writer" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.nexus_writer
    let pipeline_component = $settings.pipeline.nexus_writer
    let constant_component = $settings.constants.components.nexus_writer
    let topics = $settings.broker.topics

    # Subdirectory
    let subdir = if $instance_settings.new_broker_subdir? == null {
        $broker_component.subdirectory
    } else {
        $instance_settings.new_broker_subdir
    }

    # Paths
    let local_path = [$pipeline_component.paths.nexus_output, $subdir] | str join "/"
    let archive_path_maybe = if $instance_settings.supress_archive? == null {
        ["--archive-path", ([$pipeline_component.paths.nexus_archive, $subdir] | str join "/") ]
    } else {
        []
    }

    # Namespace
    let namespace = if $instance_settings.new_namespace? == null {
        $settings.broker.pipeline_name
    } else {
        $instance_settings.new_namespace
    }

    #Arguments
    [
        "--broker", $settings.broker.address,
        "--consumer-group", $settings.broker.consumer_groups.nexus_writer,
        "--observability-address", $constant_component.observability.obsv_address,
        "--control-topic", $topics.control,
        "--frame-event-topic", $topics.frame_event,
        "--log-topic", $topics.logs,
        "--sample-env-topic", $topics.selogs,
        "--alarm-topic", $topics.alarms,
        "--cache-run-ttl-ms", ($pipeline_component.run_ttl_ms | into string),
        "--otel-endpoint", $settings.constants.otel_endpoint,
        "--otel-namespace", $namespace,
        "--local-path", $local_path
    ] | append $archive_path_maybe
}
