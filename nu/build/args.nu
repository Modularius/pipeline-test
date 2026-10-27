use ../../settings.nu constants
#use ../../settings.nu components
use ./prelude.nu [get_nexus_local_path, get_nexus_archive_path]

# Needs fixing since add hdf5 reader
export def "build_args reader" [settings: record, instance_settings: record, file_path: string] : nothing -> list<string> {
    let component = $settings.components.reader

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name
    let frame_number = $instance_settings.frame_number? | default 0
    let digitiser_id = $instance_settings.digitiser_id? | default 0
    let number_of_trace_events = $instance_settings.number_of_trace_events? | default 1
    let random_sample = $instance_settings.random_sample? | default false

    [
        "--broker", $settings.broker.address,
        "--otel-endpoint", $constants.otel_endpoint,
        "--otel-namespace", $namespace,
        "--file-name", $file_path,
        "--trace-topic", $settings.broker.topics.trace,
        "--frame-number", $frame_number,
        "--digitiser-id", $digitiser_id,
        "--number-of-trace-events", $number_of_trace_events #,
        #"--random-sample", $random_sample
    ]
}

export def "build_args hdf5_reader" [settings: record, instance_settings: record, file_path: string, read_seq: string] : nothing -> list<string> {
    let component = $settings.components.reader

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name
    
    #let frames_maybe = [
    #    "--from-frame-number", $instance_settings.from_frame,
    #    "--to-frame-number", $instance_settings.to_frame
    #] | where ($instance_settings.use_frames? | default false)
    
    #let indices_maybe = [
    #    "--from-index", $instance_settings.from_index,
    #    "--to-index", $instance_settings.to_index
    #] | where ($instance_settings.use_indices? | default false)
    
    let sample_rate = [ "--sample_rate", ($instance_settings.sample_rate? | default 1000000000) ]
    let overwrite_period_maybe = [
        "--overwrite-period-number", ($instance_settings.overwrite_period? | default 0)
    ] | where ($instance_settings.overwrite_period? != null)
    
    let shift_to_today_maybe = ["--shift-to-today"] | where ($instance_settings.shift_to_today? | default false)
    
    [
        "--broker", $settings.broker.address,
        "--otel-endpoint", $constants.otel_endpoint,
        "--otel-namespace", $namespace,
        "--file-name", $file_path,
        "--trace-topic", $settings.broker.topics.trace,
        "--key", "read-from-file",
        "hdf5",
        "--read", $"[($read_seq)]"
    ] | append $shift_to_today_maybe
      | append $overwrite_period_maybe
}

export def "build_args writer" [settings: record, instance_settings: record, output_path: string] : nothing -> list<string> {
    let component = $settings.components.trace_writer

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name
    
    let control_topic_maybe = ["--control-topic", $settings.broker.topics.control
    ] | where ($instance_settings.use_control_topic? | default false)

    let trace_topic = $instance_settings.trace_topic? | default $settings.broker.topics.trace
    let obsv_address = $instance_settings.obsv_address? | default $component.observability.obsv_address

    [
        "--broker", $settings.broker.address,
        "--observability-address", $obsv_address,
        "--otel-endpoint", $constants.otel_endpoint,
        "--otel-namespace", $namespace,
        "--trace-topic", $trace_topic,
        "--consumer-group", $settings.broker.consumer_groups.trace_saver,
        "--chunk-size", ($settings.pipeline.trace_saver.chunk_size | into string),
        "--output", $output_path
    ] | append $control_topic_maybe
}

export def "build_args analyser" [settings: record, analysis_settings: string, chart_output: string, instance_settings: record] : nothing -> list<string> {
    let component = $settings.components.analyser

    let load_metrics_maybe = ["--load-metrics"] | where ($instance_settings.load_metrics? | default false)

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name
    [
        "--chart-output", $chart_output,
        "--observability-address", $component.observability.obsv_address,
        "--otel-endpoint", $constants.otel_endpoint,
        "--otel-namespace", $namespace,
        "evaluate",
        "--group", $settings.broker.consumer_groups.analyser,
        "--analysis-settings", $analysis_settings,
        "--eventlist-ttl-ms", "20000",
        "--broker", $settings.broker.address
    ] | append $load_metrics_maybe
}

export def "build_args simulator" [settings: record, instance_settings: record, source: string] : nothing -> list<string> {
    let component = $settings.components.simulator

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name
    let trace = $instance_settings.trace? | default $settings.broker.topics.trace
    let dat_event = $instance_settings.dat_event? | default $settings.broker.topics.dat_event
    let frame_event = $instance_settings.frame_event? | default $settings.broker.topics.frame_event
    
    let otel_endpoint_maybe = ["--otel-endpoint", $constants.otel_endpoint]
        | where ($instance_settings.use_otel? | default true)

    [
        "--broker", $settings.broker.address,
        "--otel-namespace", $namespace,
        "defined", $source,
        "--digitiser-trace-topic", $trace,
        "--digitiser-event-topic", $dat_event,
        "--frame-event-topic", $frame_event,
        "--control-topic", $settings.broker.topics.control,
        "--runlog-topic", $settings.broker.topics.logs,
        "--selog-topic", $settings.broker.topics.selogs,
        "--alarm-topic", $settings.broker.topics.alarms
    ] # | append $otel_endpoint_maybe
}

export def "build_args trace_to_events" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.trace_to_events
    let component = $settings.components.trace_to_events
    
    let topics = $settings.broker.topics

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name
    
    let otel_endpoint_maybe = ["--otel-endpoint", $constants.otel_endpoint]
        | where ($instance_settings.use_otel? | default true)
    
    [
        "--broker", $settings.broker.address,
        "--consumer-group", $settings.broker.consumer_groups.trace_to_events,
        "--observability-address", $component.observability.obsv_address,
        "--trace-topic", $topics.trace,
        "--event-topic", $topics.dat_event,
        "--polarity", $broker_component.polarity,
        "--baseline", ($broker_component.baseline | into string),
        "--send-eventlist-buffer-size", ($settings.pipeline.trace_to_events.send_eventlist_buffer_size | into string),
        "--otel-namespace", $namespace
    ] | append $otel_endpoint_maybe
      | append $settings.detector
}

export def "build_args digitiser_aggregator" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.digitiser_aggregator
    let pipeline_component = $settings.pipeline.digitiser_aggregator
    let component = $settings.components.digitiser_aggregator

    let topics = $settings.broker.topics
    
    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name

    let otel_endpoint_maybe = ["--otel-endpoint", $constants.otel_endpoint]
        | where ($instance_settings.use_otel? | default true)
    
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
    ] | append $otel_endpoint_maybe
      | append $digitiser_ids
}

def build_configuration_options [settings: record, instance_settings: record] : nothing -> string {
    let local_path = get_nexus_local_path $settings $instance_settings
    let archive_path = if ($instance_settings.suppress_archive? | default false) {
        ""
    } else {
        get_nexus_archive_path $settings $instance_settings
    }

    {
        "pipeline_name": $settings.broker.pipeline_name,
        "address": $settings.broker.address,
        "topics": $settings.broker.topics,
        "consumer_groups": $settings.broker.consumer_groups,
        "trace_to_events": ($settings.broker.trace_to_events | merge $settings.pipeline.trace_to_events),
        "digitiser_aggregator": ($settings.broker.digitiser_aggregator | merge $settings.pipeline.digitiser_aggregator),    
        "nexus_writer": {
            "paths": {
                "nexus_output": $local_path,
                "nexus_archive": $archive_path,
            },
            "run_ttl_ms": $settings.pipeline.nexus_writer.run_ttl_ms
        },
        "detector": $settings.detector
    } | to json --raw
}

export def "build_args nexus_writer" [settings: record, instance_settings: record] : nothing -> list<string> {
    let broker_component = $settings.broker.nexus_writer
    let pipeline_component = $settings.pipeline.nexus_writer
    let component = $settings.components.nexus_writer
    let topics = $settings.broker.topics

    # Paths
    let local_path = $instance_settings.new_local_path?
        | default (get_nexus_local_path $settings $instance_settings)
    let archive_path_maybe = ["--archive-path", (
        $instance_settings.new_archive_path?
            | default (get_nexus_archive_path $settings $instance_settings)
        )
    ] | where ($instance_settings.suppress_archive? | default false) == false

    # Namespace
    let namespace = $instance_settings.new_namespace? | default $settings.broker.pipeline_name
    
    let otel_endpoint_maybe = ["--otel-endpoint", $constants.otel_endpoint]
        | where ($instance_settings.use_otel? | default true)
    
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
        "--configuration-options", (build_configuration_options $settings $instance_settings),
        "--cache-run-ttl-ms", ($pipeline_component.run_ttl_ms | into string),
        "--otel-namespace", $namespace,
        "--local-path", $local_path
    ] | append $otel_endpoint_maybe
      | append $archive_path_maybe
}

export def "build_args diagnostics" [settings: record] : nothing -> list<string> {    #Arguments
    [
        "daq-trace",
        "--broker", $settings.broker.address,
        "--group", $settings.broker.consumer_groups.diagnostics,
        "--topic", $settings.broker.topics.trace,
    ]
}
