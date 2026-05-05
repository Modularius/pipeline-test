use ../build/prelude.nu [print_title, print_heading]
use ../../settings.nu [components, constants, brokers, pipeline_settings, detector_settings]
use ../build/settings.nu ['SETTINGS_PATH', 'build_settings']
use ../build/detector.nu [build_record_from_random_intervals, build_detector]

def main [] {
    "Exploring Parameter Space" | print_title
    let template = {
        "type": "fixed-threshold-discriminator",
        "threshold": 0,
        "duration": 1,
        "cool-off": 0,
    };

    let tests = ["1500","2000","2500","3000"]
        | each {|value| $template
        | update threshold $value | build_detector}

    $tests | each {|test|
        "Loading Detector Settings" | print_heading "red"
        $test | print
        "Running Test" | print_heading "red"
        init_custom_settings_detector local pipeline_1 $test
        nu nu/run_pipeline.nu container standard
        sleep 2sec
        nu nu/run_pipeline.nu host param_explore_simulator
        sleep 2sec
        nu nu/kill.nu container
        nu nu/tools/clean.nu param_explore_simulator
    }
}

def init_custom_settings_detector [broker: string, pipeline: string, detector: list<string>] {
    let settings = build_settings $broker $pipeline "threshold_1"
    let settings = $settings
        | update detector $detector
    $settings | save -f $SETTINGS_PATH
}

def init_custom_settings2 [broker: string, pipeline: string, detector: list<string>, affix: string] {
    let settings = build_settings $broker $pipeline "threshold_1"
    let settings = $settings
        | update detector $detector
        | update components.trace_to_events.observability ([127.0.0.1:2901, $affix] | str join "")
        | update components.digitiser_aggregator.observability ([127.0.0.1:2902, $affix] | str join "")
        | update components.nexus_writer.observability ([127.0.0.1:2903, $affix] | str join "")
        | update broker.pipeline_name ([$settings.broker.pipeline_name, $affix] | str join "_")
        | update broker.nexus_writer.subdirectory ([$settings.broker.nexus_writer.subdirectory, $affix] | str join "_")
        | update broker.topics.dat_event ([$settings.broker.topics.dat_event, $affix] | str join "_")
        | update broker.topics.frame_event ([$settings.broker.topics.frame_event, $affix] | str join "_")
        | update broker.consumer_groups.trace_to_events ([$settings.broker.consumer_groups.trace_to_events, $affix] | str join "-")
        | update broker.consumer_groups.digitiser_aggregator ([$settings.broker.consumer_groups.digitiser_aggregator, $affix] | str join "-")
        | update broker.consumer_groups.nexus_writer ([$settings.broker.consumer_groups.nexus_writer, $affix] | str join "-")
    $settings | save -f $SETTINGS_PATH
}
#podman pod rm pod_local_0 pod_local_1 pod_local_2 pod_local_3 -f