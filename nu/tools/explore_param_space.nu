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

    #let tests = ["500", "750", "1000", "1250", "1500", "1750", "2000"]
    let tests = ["900", "950", "1000", "1050", "1100", "1150", "1200"]
        | each {|value| $template
        | update threshold $value | build_detector}

    $tests | enumerate | each {|test|
        $"Running Test ($test)" | print_heading "red"
        $test.item | print
        "Running Test" | print_heading "red"
        init_custom_settings_detector local param_space $test.item $test.index

        nu nu/tools/clean.nu remove param_space_simulator
        nu nu/tools/clean.nu create param_space_simulator

        nu nu/run_pipeline.nu param_space standard
        sleep 2sec
        nu nu/run_pipeline.nu param_space param_space_simulator
        sleep 2sec
        nu nu/kill.nu param_space
        #nu nu/tools/clean.nu remove param_space_simulator
    }
}

def init_custom_settings_detector [broker: string, pipeline: string, detector: list<string>, test_index: int] {
    let settings = build_settings $broker $pipeline "threshold_1"
    let settings = $settings
        | update detector $detector
        | update broker.nexus_writer.subdirectory ($test_index | into string)
    $settings | save -f $SETTINGS_PATH
}
#podman pod rm pod_local_0 pod_local_1 pod_local_2 pod_local_3 -f