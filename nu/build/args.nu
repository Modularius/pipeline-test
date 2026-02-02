use ./settings.nu constants
use ./settings.nu components
use ./prelude.nu [get_nexus_local_path, get_nexus_archive_path]

export def "build_args simulator" [settings: record, instance_settings: record, source: string] : nothing -> list<string> {
    let component = $components.simulator

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name

    [
        "--broker", $settings.broker.address,
        "--otel-endpoint", $constants.otel_endpoint,
        "--otel-namespace", $namespace,
        "defined", $source,
        "--digitiser-trace-topic", $settings.broker.topics.trace,
        "--digitiser-event-topic", $settings.broker.topics.dat_event,
        "--frame-event-topic", $settings.broker.topics.frame_event,
        "--control-topic", $settings.broker.topics.control,
        "--runlog-topic", $settings.broker.topics.logs,
        "--selog-topic", $settings.broker.topics.selogs,
        "--alarm-topic", $settings.broker.topics.alarms
    ]
}

export def "build_args trace_to_events" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.trace_to_events
    let component = $components.trace_to_events
    
    let topics = $settings.broker.topics

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name

    [
        "--broker", $settings.broker.address,
        "--consumer-group", $settings.broker.consumer_groups.trace_to_events,
        "--observability-address", $component.observability.obsv_address,
        "--trace-topic", $topics.trace,
        "--event-topic", $topics.dat_event,
        "--polarity", $broker_component.polarity,
        "--baseline", ($broker_component.baseline | into string),
        "--send-eventlist-buffer-size", ($settings.pipeline.trace_to_events.send_eventlist_buffer_size | into string)
        "--otel-endpoint", $constants.otel_endpoint,
        "--otel-namespace", $namespace
    ] | append $settings.detector
}

export def "build_args digitiser_aggregator" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.digitiser_aggregator
    let pipeline_component = $settings.pipeline.digitiser_aggregator
    let component = $components.digitiser_aggregator

    let topics = $settings.broker.topics
    
    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name

    let digitiser_ids = $settings.broker.digitiser_aggregator.digitiser_ids
        | each {into string}
        | each {|digitiser_id| "-d" ++ $digitiser_id}

    [
        "--broker", $settings.broker.address,
        "--group", $settings.broker.consumer_groups.digitiser_aggregator,
        "--observability-address", $component.observability.obsv_address,
        "--input-topic", $topics.dat_event,
        "--output-topic", $topics.frame_event,
        "--frame-ttl-ms", ($pipeline_component.frame_ttl_ms | into string),
        "--send-frame-buffer-size", ($pipeline_component.send_frame_buffer_size | into string),
        "--otel-endpoint", $constants.otel_endpoint,
        "--otel-namespace", $namespace
    ] | append $digitiser_ids
}

export def "build_args nexus_writer" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.nexus_writer
    let pipeline_component = $settings.pipeline.nexus_writer
    let component = $components.nexus_writer
    let topics = $settings.broker.topics

    # Paths
    let local_path = get_nexus_local_path $settings $instance_settings
    let archive_path_maybe = ["--archive-path", get_nexus_archive_path $settings $instance_settings]
        | where ($instance_settings.suppress_archive? | default false) == false

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name

    #Arguments
    [
        "--broker", $settings.broker.address,
        "--consumer-group", $settings.broker.consumer_groups.nexus_writer,
        "--observability-address", $component.observability.obsv_address,
        "--control-topic", $topics.control,
        "--frame-event-topic", $topics.frame_event,
        "--log-topic", $topics.logs,
        "--sample-env-topic", $topics.selogs,
        "--alarm-topic", $topics.alarms,
        "--cache-run-ttl-ms", ($pipeline_component.run_ttl_ms | into string),
        "--otel-endpoint", $constants.otel_endpoint,
        "--otel-namespace", $namespace,
        "--local-path", $local_path
    ] | append $archive_path_maybe
}

export def "build_args diagnostics" [settings: record] : nothing -> list<string> {    #Arguments
    [
        "daq-trace",
        "--broker", $settings.broker.address,
        "--group", $settings.broker.consumer_groups.diagnostics,
        "--topic", $settings.broker.topics.trace,
    ]
}
