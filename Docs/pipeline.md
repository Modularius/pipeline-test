# Pipeline
The command to enter the dev shell is
```shell
nix develop ../supermusr-data-pipeline/
```

The command to run the Jaeger docker collector is
`docker compose --env-file ./configs/.env.hifi -f "./Docker/docker-compose.yaml" --profile=no-broker up -d`

The command to run the Jaeger docker all-in-one is
`docker compose --env-file ./configs/.env.hifi -f "./Docker/jaeger.yaml" --profile=all-in-one up -d`

To run the daq diagnostic tool run
`cargo run --bin diagnostics daq-trace --broker 130.246.55.29:9090 --topic daq-traces-in  --group vis-3`

```mermaid

erDiagram
    TRACE_SOURCE["Trace Source Message"] {
        module various
        target otel
        level info
    }
    TRACE_SOURCE |o..|| EVENT_FORMATION : "Via Kafka"
    EVENT_FORMATION["DAT Event List"] {
        module event-formation
        target otel
        level info
    }
    EVENT_FORMATION ||--|| PROCESS : ""
    PROCESS["process"] {
        module event-formation
        target module
        level trace
    }

    EVENT_FORMATION ||..|| ON_MESSAGE : "Via Kafka"

    ON_MESSAGE["on_message"] {
        module aggregator
        target module
        level info
    }
    FRAME["Frame"] {
        module aggregator
        target otel
        level info
    }
    FRAME ||--o{ DAT_EVENT_LIST : ""
    ON_MESSAGE ||--|| DAT_EVENT_LIST : "follows from"
    DAT_EVENT_LIST["Digitiser Event List"] {
        module aggregator
        target otel
        level info
    }

    FRAME ||..|| PROCESS_KAFKA : "Via Kafka"
    PROCESS_KAFKA["Process Kafka Message"] {
        module nexus-writer
        target module
        level info
    }
    PROCESS_PAYLOAD["process_payload"] {
        module nexus-writer
        target module
        level trace
    }
    PROCESS_START["process_run_start_message"] {
        module nexus-writer
        target module
        level trace
    }
    PROCESS_STOP["process_run_stop_message"] {
        module nexus-writer
        target module
        level trace
    }
    RUN["Run"] {
        module nexus-writer
        target otel
        level info
    }
    RUN ||--|| RUN_START_COMMAND : ""
    RUN_START_COMMAND["Run Start Command"] {
        module nexus-writer
        target otel
        level info
    }
    RUN ||--o{ FRAME_EVENT_LIST : ""
    FRAME_EVENT_LIST["Frame Event List"] {
        module nexus-writer
        target otel
        level info
    }
    RUN ||--|| RUN_STOP_COMMAND : ""
    RUN_STOP_COMMAND["Run Stop Command"] {
        module nexus-writer
        target otel
        level info
    }
    PROCESS_FRAME["process_frame_assembled_event_list_message"] {
        module nexus-writer
        target module
        level trace
    }

    PROCESS_KAFKA ||--|| PROCESS_PAYLOAD : ""
    PROCESS_PAYLOAD ||--o| PROCESS_START : ""
    PROCESS_START ||--|| RUN_START_COMMAND : "follows from"
    PROCESS_PAYLOAD ||--o| PROCESS_FRAME : ""
    PROCESS_FRAME ||--|| FRAME_EVENT_LIST : "follows from"
    PROCESS_PAYLOAD ||--o| PROCESS_STOP : ""
    PROCESS_STOP ||--|| RUN_STOP_COMMAND : "follows from"

```