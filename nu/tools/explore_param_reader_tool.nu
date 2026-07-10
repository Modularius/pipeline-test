use ../build/prelude.nu [print_title, print_heading]
use ../../settings.nu [components, constants, brokers, pipeline_settings, detector_settings]
use ../build/settings.nu ['SETTINGS_PATH', 'build_settings']
use ../build/detector.nu [build_record_from_random_intervals, build_detector]
use ../modes/closures.nu mode

def main [] {
    "Exploring Parameter Space" | print_title
    let tests = [
        {
            "type": "fixed-threshold-discriminator",
            "threshold": 220,
            "duration": 1,
            "cool-off": 5
        }]
        [
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
            "type": "smoothing-detector",
            "noise-centile": 90,
            "kernel-sigma": 2,
            "nsig-noise": 5,
            "min-size": 5
        },
        {
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
                "cool-off": 0
            }
        }
    ]
    
    let tests = $tests | each {|template| $template | build_detector}
    print $tests
    let settings = build_settings "local" "param_space" "threshold_1"
    #$settings.detector | print

    let mode = mode "param_space" $settings
    let chart_output = "/home/ubuntu/SuperMuSRDataPipeline/pipeline-test/evaluation/output"
    let analysis_settings = "/home/ubuntu/SuperMuSRDataPipeline/pipeline-test/evaluation/slit_analysis.json"
    do $mode.run_analyser $chart_output $analysis_settings

    $tests | enumerate | each {|test|
        $"Running Test ($test.index)" | print_heading "red"
        "Running Test" | print_heading "red"
        init_custom_settings_detector $settings $test.item $test.index
        
        nu nu/run_pipeline.nu param_space standard
        sleep 1sec
        nu nu/run_pipeline.nu param_space param_space_reader
        sleep 1sec
        nu nu/kill.nu param_space
    }
}

def init_custom_settings_detector [settings: record, detector: list<string>, test_index: int] {
    let settings = $settings
        | update detector $detector
        | insert test_index $test_index
    $settings | save -f $SETTINGS_PATH
}
#podman pod rm pod_local_0 pod_local_1 pod_local_2 pod_local_3 -f