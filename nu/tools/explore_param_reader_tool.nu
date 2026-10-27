use ../build/prelude.nu [print_title, print_heading]
use ../../settings.nu [components, constants, brokers, pipeline_settings, detector_settings]
use ../build/settings.nu ['SETTINGS_PATH', 'build_settings']
use ../build/detector.nu [build_record_from_random_intervals, build_detector]
use ../modes/closures.nu mode

let tests1 = [
    {
        "type": "fixed-threshold-discriminator",
        "threshold": 2150,
        "duration": 2,
        "cool-off": 3
    },
    {
        "type": "fixed-threshold-discriminator",
        "threshold": 2200,
        "duration": 2,
        "cool-off": 3
    },
    {
        "type": "fixed-threshold-discriminator",
        "threshold": 2250,
        "duration": 2,
        "cool-off": 3
    },
    {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 5,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    },
    {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 20,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    },
    {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 35,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    },
    {
        "type": "smoothing-detector",
        "noise-centile": 90,
        "kernel-sigma": 2,
        "nsig-noise": 2,
        "min-size": 5
    },
    {
        "type": "smoothing-detector",
        "noise-centile": 90,
        "kernel-sigma": 2,
        "nsig-noise": 5,
        "min-size": 5
    },
    {
        "type": "smoothing-detector",
        "noise-centile": 90,
        "kernel-sigma": 2,
        "nsig-noise": 7,
        "min-size": 5
    }
]

let tests2 = [
    {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 15,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    },
    {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 25,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    },
    {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 5,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    }
]


let tests3 = [
    {
        "type": "fixed-threshold-discriminator",
        "threshold": 200,
        "duration": 2,
        "cool-off": 3
    },
    {
        "type": "differential-threshold-discriminator",
        "begin-threshold": 20,
        "end-threshold": 0,
        "begin-duration": 2,
        "end-duration": 0,
        "cool-off": 0
        "peak-height-mode": "value-at-end-trigger",
        "peak-height-basis": "trace-baseline"
    },
    {
        "type": "smoothing-detector",
        "noise-centile": 90,
        "kernel-sigma": 2,
        "nsig-noise": 5,
        "min-size": 5
    }
]

let multiscale_tests = $tests3 | each {
    |underlying| {
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
        "underlying": $underlying
    }
}
let multiscale_tests = []
let tests = $tests1 ++ $multiscale_tests | each {|template| $template | build_detector}

export def 'main' [] {
    "Exploring Parameter Space" | print_title
    let settings = build_settings "local" "param_space" "threshold_1"
    $settings | save -f $SETTINGS_PATH
    
    let mode = mode "param_space" $settings
    let chart_output = "/home/ubuntu/SuperMuSRDataPipeline/pipeline-test/evaluation/output/six_detectors_intensity_graph"
    let analysis_settings = "/home/ubuntu/SuperMuSRDataPipeline/pipeline-test/evaluation/input/six_detectors_intensity_graph.json"
    #do $mode.run_analyser $chart_output $analysis_settings { load_metrics: false }

    $tests | enumerate | each {|test|
        $"Setting up Test ($test.index) pipeline" | print_heading "red"
        let settings = $settings
            | update_pipeline_name_and_topic ($test.index | into string)
            | init_custom_settings_detector $test.item $test.index

        let mode = mode "param_space" $settings
        do $mode.deploy_pipeline { }
    }
}

export def 'main kill analyser' [] {
    "Killing Parameter Space (Analyser Only)" | print_title
    let settings = build_settings "local" "param_space" "threshold_1"
    
    let mode = mode "param_space" $settings
    do $mode.kill_analyser
}

export def 'main kill' [] {
    "Killing Parameter Space" | print_title
    let settings = build_settings "local" "param_space" "threshold_1"
    
    let mode = mode "param_space" $settings
    do $mode.kill_analyser

    $tests | enumerate | each {|test|
        $"Running Test ($test.index)" | print_heading "red"
        let settings = $settings
            | update_pipeline_name_and_topic ($test.index | into string)

        let mode = mode "param_space" $settings
        do $mode.kill_pipeline { }
    }
}

def update_pipeline_name_and_topic [suffix: string] : record -> record {
    $in | update broker.pipeline_name ([$in.broker.pipeline_name, $suffix ] | str join '_')
        | update broker.topics.dat_event ([$in.broker.topics.dat_event, $suffix ] | str join '_')
        | update broker.trace_to_events.baseline 0
        | update broker.consumer_groups.trace_to_events ([$in.broker.consumer_groups.trace_to_events, $suffix ] | str join '_')
        | update components.trace_to_events.observability.obsv_address $"127.0.0.1:2909($suffix)"
}

def init_custom_settings_detector [detector: list<string>, test_index: int] : record -> record {
    $in | update detector $detector
        | insert test_index $test_index
}
#podman pod rm pod_local_0 pod_local_1 pod_local_2 pod_local_3 -f