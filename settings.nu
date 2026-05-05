const prefix = "../digital-muon-pipeline/target/release/"
#const prefix = "../digital-muon-pipeline/target/debug/"
#const prefix = "cargo run --manifest-path "../supermusr-data-pipeline" --release --bin "
#ghcr.io/isisneutronmuon/digital-muon- :main

export const components = {
    trace_to_events: {
        execution_path: ($prefix ++ "trace-to-events"), process_name: "trace-to-events" container_image: "supermusr-trace-to-events:latest",
        image_env_vars: { image: "IMAGE_EVENT_FORMATION", obvs_port: "OBSV_ADDRESS_EVENT_FORMATION", args: "EVENT_FORMATION_ARGS" },
        observability: { obsv_address: "127.0.0.1:29090" tracing_level: "info", otel_level: "info,trace_to_events::channels=warn,trace_to_events::pulse_detection=warn" }
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
        observability: { obsv_address: "127.0.0.1:29093" tracing_level: "debug", otel_level: "info" }
    },
    reader: {
        execution_path: ($prefix ++ "trace-reader"), process_name: "trace-reader" container_image: "ghcr.io/isisneutronmuon/digital-trace-reader:main",
        image_env_vars: { image: "IMAGE_READER", obvs_port: "OBSV_ADDRESS_READER", args: "READER_ARGS" },
        observability: { obsv_address: "127.0.0.1:29094" tracing_level: "warn", otel_level: "warn" }
    },
    diagnostics: {
        execution_path: ($prefix ++ "diagnostics"), process_name: "diagnostics" container_image: "supermusr-diagnostics:latest"
    }
}

export const constants = {
    no_color_env: true,
    rust_log: "info",
    otel_level: "info",
    otel_endpoint: "http://172.16.105.83:4317",
    rust_backtrace: "1"
}

export const detector_settings_intervals = {
    threshold_1: {
        "type": "fixed-threshold-discriminator",
        "threshold": 1005,
        "duration": 1,
        "cool-off": 0,
    }
    differential_1: {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 25,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    },
    smoothing_1: {
        "type": "smoothing-detector",
        "noise-centile": 90,
        "kernel-sigma": 2,
        "nsig-noise": 5,
        "min-size": 5 #,
        #"--use-local-for-sizes-ge", "2"
    },
    multiscale_1: {
        "type": "multiscaling",
        "downsampling-smoothing": [0.125,0.5,0.75,0.5,0.125],
        "smoothing-support": [-2,-1,0,1,2],
        "fft-padding": 200,
        "fft-truncation": 20,
        "number-of-layers": 4,
        "denoise": true,
        "denoise-thresholds": [50,50,50,50],
        "enhance": true,
        "enhance-thresholds": [50,50,50,50],
        "enhance-factors": [1.05,1.05,1.05,1.05],
        "multiply": true,
        "multiply-factors": [1.01,1.01,1.01,1.01],
        "underlying": {
            "type": "fixed-threshold-discriminator",
            "threshold": 1500,
            "duration": 1,
            "cool-off": 0,
        }
        #"--use-local-for-sizes-ge", "2"
    },
}

export const detector_settings = {
    threshold_1: {
        "type": "fixed-threshold-discriminator",
        "threshold": { min: 200, max: 2000, dflt: 1500},
        "duration": { min: 1, max: 5, dflt: 3},
        "cool-off": { min: 0, max: 3, dflt: 0},
    }
    differential_1: {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 25,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    },
    smoothing_1: {
        "type": "smoothing-detector",
        "noise-centile": 90,
        "kernel-sigma": 2,
        "nsig-noise": 5,
        "min-size": 5 #,
        #"--use-local-for-sizes-ge", "2"
    },
    multiscale_1: {
        "type": "multiscaling",
        "downsampling-smoothing": [0.125,0.5,0.75,0.5,0.125],
        "smoothing-support": [-2,-1,0,1,2],
        "fft-padding": 200,
        "fft-truncation": 20,
        "number-of-layers": 4,
        "denoise": true,
        "denoise-thresholds": [50,{ min: 1, max: 100, dflt: 50},50,50],
        "enhance": true,
        "enhance-thresholds": [50,50,50,50],
        "enhance-factors": [1.05,1.05,1.05,1.05],
        "multiply": true,
        "multiply-factors": [1.01,1.01,1.01,1.01],
        "underlying": {
            "type": "fixed-threshold-discriminator",
            "threshold": { min: 200, max: 2000, dflt: 1500},
            "duration": 1,
            "cool-off": 0,
        }
        #"--use-local-for-sizes-ge", "2"
    },
}

#### Event Formation
export const detector_settings_legacy = {
    threshold_1: [ "fixed-threshold-discriminator",
        "--threshold", "5",
        "--duration", "1",
        "--cool-off", "0"
    ],
    threshold_2: {
        "threshold": "5",
        "duration": "1",
        "cool-off": "0",
    }
    differential_1: [ "differential-threshold-discriminator",
        "--begin-threshold", "25",
        "--end-threshold", "0",
        "--begin-duration", "2",
        "--end-duration", "0",
        "--cool-off", "0"
        "--peak-height-mode", "value-at-end-trigger",
        "--peak-height-basis", "trace-baseline"
    ],
    smoothing_1: [ "smoothing-detector",
        "--noise-centile", "90",
        "--kernel-sigma", "2",
        "--nsig-noise", "5",
        "--min-size", "5" #,
        #"--use-local-for-sizes-ge", "2"
    ],
    multiscale_1: [ "multiscaling",
        "--downsampling-smoothing", "0.125,0.5,0.75,0.5,0.125",
        "--smoothing-support=-2,-1,0,1,2",
        "--fft-padding", "200",
        "--fft-truncation", "20",
        "--number-of-layers", "4",
        "--denoise",
        "--denoise-thresholds","50,50,50,50",
        "--enhance",
        "--enhance-thresholds", "50,50,50,50" ,
        "--enhance-factors", "1.05,1.05,1.05,1.05",
        "--multiply",
        "--multiply-factors", "1.01,1.01,1.01,1.01",
        "fixed-threshold-discriminator",
        "--threshold", "2500",
        "--duration", "3",
        "--cool-off", "5"
        #"--use-local-for-sizes-ge", "2"
    ],
    multiscale_2: [ "multiscaling",
        "--downsampling-smoothing", "0.125,0.5,0.75,0.5,0.125",
        "--smoothing-support=-2,-1,0,1,2",
        "--fft-padding", "200",
        "--fft-truncation", "20",
        "--number-of-layers", "4",
        "--denoise",
        "--denoise-thresholds","50,50,50,50",
        "--enhance",
        "--enhance-thresholds", "50,50,50,50" ,
        "--enhance-factors", "1.05,1.05,1.05,1.05",
        "--multiply",
        "--multiply-factors", "1.01,1.01,1.01,1.01",
        "differential-threshold-discriminator",
        "--begin-threshold", "25",
        "--end-threshold", "0",
        "--begin-duration", "2",
        "--end-duration", "0",
        "--cool-off", "0"
        "--peak-height-mode", "value-at-end-trigger",
        "--peak-height-basis", "trace-baseline"
    ],
    multiscale_3: [ "multiscaling",
        "--downsampling-smoothing", "0.125,0.5,0.75,0.5,0.125",
        "--smoothing-support=-2,-1,0,1,2",
        "--fft-padding", "200",
        "--fft-truncation", "20",
        "--number-of-layers", "4",
        "--denoise",
        "--denoise-thresholds","50,50,50,50",
        "--enhance",
        "--enhance-thresholds", "50,50,50,50" ,
        "--enhance-factors", "1.05,1.05,1.05,1.05",
        "--multiply",
        "--multiply-factors", "1.01,1.01,1.01,1.01",
        "smoothing-detector",
        "--noise-centile", "90",
        "--kernel-sigma", "2",
        "--nsig-noise", "5",
        "--min-size", "1" #,
        #"--use-local-for-sizes-ge", "2"
    ]
}

export const pipeline_settings = {
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
export const brokers = {
    local_one_digitiser: {
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
            digitiser_ids: [0]
        },
        nexus_writer: {
            subdirectory: "local",
        }
    },
    local_musr_reader: {
        pipeline_name: "local_musr_file",
        address: "localhost:19092",
        topics:             { trace: "Traces", dat_event: "Events", frame_event: "FrameEvents", control: "Controls", logs: "Logs", selogs: "SELogs", alarms: "Alarms" },
        consumer_groups:    { trace_to_events: "trace_to_events", digitiser_aggregator: "digitiser_aggregator", nexus_writer: "nexus_writer", diagnostics: "diagnostics" },
        # Trace Source Dependent Event Formation Settings
        trace_to_events: {
            polarity: "negative",
            baseline: 100
        },
        digitiser_aggregator: {
            digitiser_ids: [0]
        },
        nexus_writer: {
            subdirectory: "local",
        }
    },
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
    local_direct: {
        pipeline_name: "local_direct",
        address: "localhost:19092",
        topics:             { trace: "Traces", dat_event: "Events_direct", frame_event: "FrameEvents_direct", control: "Controls", logs: "Logs", selogs: "SELogs", alarms: "Alarms" },
        consumer_groups:    { trace_to_events: "trace_to_events", digitiser_aggregator: "digitiser_aggregator_direct", nexus_writer: "nexus_writer_direct", diagnostics: "diagnostics" },
        # Trace Source Dependent Event Formation Settings
        trace_to_events: {
            polarity: "positive",
            baseline: 0
        },
        digitiser_aggregator: {
            digitiser_ids: [0,1,2,3,4,5,6,7]
        },
        nexus_writer: {
            subdirectory: "local_direct",
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
            digitiser_ids: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31] #,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119]
        },
        nexus_writer: {
            subdirectory: "local",
        }
    },
    hifi: {
        pipeline_name: "hifi-via-local",
        address: "130.246.55.29:9092",
        topics:             { trace: "daq-traces-in", dat_event: "local-daq-events", frame_event: "local-frame-events", control: "ics-control-change", logs: "ics-metadata", selogs: "HIFI_sampleEnv", alarms: "ics-alarms" },
        consumer_groups:    { trace_to_events: "local_trace_to_events", digitiser_aggregator: "local_digitiser_aggregator", nexus_writer: "local_nexus_writer", diagnostics: "local_diagnostics" },
        # Trace Source Dependent Event Formation Settings
        trace_to_events: {
            polarity: "positive",
            baseline: 0
        },
        digitiser_aggregator: {
            digitiser_ids: [4,5,6,7,8,9,10,11]
        },
        nexus_writer: {
            subdirectory: "hifi-via-local",
        }
    },
    hifi-test-simulator-only: {
        pipeline_name: "hifi-test",
        address: "130.246.55.29:9092",
        topics: { trace: "test-traces-in", dat_event: "test-daq-events", frame_event: "test-frame-events", control: "test-control-change", logs: "test-metadata", selogs: "test-SELogsHIFI_sampleEnv", alarms: "test-alarms" },
    },
}
