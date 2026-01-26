use ../prelude.nu print_heading
use std/assert

const HEADING_COLOUR = "red"
const SUBHEADING_COLOUR = "blue"
const SUBSUBHEADING_COLOUR = "purple"

def analyse_test_file [path: string] {
    $"Analysing Test File: ($path)" | print_heading $SUBHEADING_COLOUR

    let top_level = h5ls $path | split row "\n" | split column -c " " "path" "type" "datatype"
    assert equal $top_level [["path", "type"]; ["raw_data_1", "Group"]]

    let raw_data_1 = h5ls $"($path)/raw_data_1" | split row "\n" | split column -c " " "path" "type" "datatype"
    assert equal ($raw_data_1 | length) 17
    assert equal ($raw_data_1 | where {|row|$row.path == "detector_1_events"}) [["path", "type"]; ["detector_1_events", "Group"]]

    let detector_1_events = h5ls $"($path)/raw_data_1/detector_1_events" | split row "\n" | split column -c " " "path" "type" "datatype"
    assert equal ($detector_1_events | get "path") [
        "event_id",
        "event_index",
        "event_time_offset",
        "event_time_zero",
        "frame_complete",
        "frame_number",
        "period_number",
        "pulse_height",
        "running",
        "veto_flags"
    ]
    "Analysing 'detector_1_events'" | print_heading $SUBSUBHEADING_COLOUR
    let num_events = ($detector_1_events.datatype | get 0)
    let num_frames = ($detector_1_events.datatype | get 1)
    $"Frames: ($num_frames), Events: ($num_events)" | print
    assert equal $num_events ($detector_1_events.datatype | get 2) "event_time_offset"
    assert equal $num_events ($detector_1_events.datatype | get 7) "pulse_height"

    assert equal $num_frames ($detector_1_events.datatype | get 3) "event_time_zero"
    assert equal $num_frames ($detector_1_events.datatype | get 4) "frame_complete"
    assert equal $num_frames ($detector_1_events.datatype | get 5) "frame_number"
    assert equal $num_frames ($detector_1_events.datatype | get 6) "period_number"
    assert equal $num_frames ($detector_1_events.datatype | get 8) "running"
    assert equal $num_frames ($detector_1_events.datatype | get 9) "veto_flags"
    

    "Analysing 'runlog'" | print_heading $SUBSUBHEADING_COLOUR
    let runlog = h5ls $"($path)/raw_data_1/runlog" | split row "\n" | split column -c " " "path" "type" "datatype"
    if $runlog == [{}] {
        "Runlog empty" | print
    } else {
        for rl in $runlog {
            $"Runlog: ($rl.path)" | print
            let time = h5ls -d $"($path)/raw_data_1/runlog/($rl.path)/time"| split row "\n" | skip 2 | str join "" | split words
            let value = h5ls -d $"($path)/raw_data_1/runlog/($rl.path)/value"| split row "\n" | skip 2 | str join "" | str trim -c " " | split row ", " | str trim -c '"'
            assert equal ($time | length) ($value | length)
            [["time", "value"]] | append ($time | zip $value) | each { { 0: $in.0, 1: $in.1 } } | headers | print
            #[["value"]; [($value | each {|t|[t]})]] | print
            #let log = [["time"]; [($time | each {|t|[t]})]] | merge [["value"]; [($value | each {|t|[t]})]]
            #$log | table | print
        }
    }

    "Analysing 'selog'" | print_heading $SUBSUBHEADING_COLOUR
    let selog = h5ls $"($path)/raw_data_1/selog" | split row "\n" | split column -c " " "path" "type" "datatype"
    if $selog == [{}] {
        "Selog empty" | print
    } else {
        $selog | print
        for sl in $selog {
            $sl | print
            $"Runlog: ($sl.path)" | print
            let time = h5ls -d $"($path)/raw_data_1/runlog/($sl.path)/time"| split row "\n" | skip 2 | str join "" | split words
            let value = h5ls -d $"($path)/raw_data_1/runlog/($sl.path)/value"| split row "\n" | skip 2 | str join "" | str trim -c " " | split row ", " | str trim -c '"'
            #h5ls -d $"($path)/raw_data_1/runlog/($rl.path)/value" | str replace "\n" " " | print
            $time | print
            $value | print
        }
    }
    
    "Test File Analysis Complete" | print_heading $SUBHEADING_COLOUR
}

### This indicates that we do not change the default nexus file subdirectory.
export def new_subdir [] : nothing -> oneof<string,nothing> { null }

export def main [deploy_pipeline: closure, run_simulator: closure, kill_pipeline: closure] {
    "Running Tests Execution" | print_heading $HEADING_COLOUR

    let pipeline_and_simulation = {|simulation: string, sim_env_vars: record|
        do $deploy_pipeline {"suppress_archive": true}; sleep 1sec

        do $run_simulator $"Simulations/Tests/($simulation).json" $sim_env_vars {}; sleep 1sec

        let run_name = ($sim_env_vars | get "RUN_NAME")
        let completed_path = $"Output/local/completed/($run_name).nxs"
        while not ($completed_path | path exists) { sleep 1sec }
        let path = $"Output/local/($run_name).nxs"
        while ($path | path exists) { sleep 1sec }

        analyse_test_file $completed_path
    }

    do $pipeline_and_simulation "SanityChecking/one_run" {
        RUN_NAME: "New_Run", TIME_BINS: 10000,
        LAST_FRAME: 1, NUM_DIGITISERS: 8, LAST_DIGITISER: 7,
        NUM_PULSES: 100, PULSE_MEAN_LIFETIME: 1000
    }

    do $kill_pipeline; sleep 1sec

    nu ./nu/clean.nu "benchmark"; sleep 1sec
}