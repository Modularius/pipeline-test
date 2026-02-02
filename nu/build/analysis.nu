use ../build/prelude.nu [print_heading, HEADING_COLOUR, SUBHEADING_COLOUR, SUBSUBHEADING_COLOUR, SUBSUBSUBHEADING_COLOUR]
use std/assert

def is_monotonic [] : list<int> -> bool {
    $in
}
  
def summary_stats [path: string, field: string, do_monotonic?: bool] : nothing -> record {
    let data = h5ls -d $"($path)/raw_data_1/detector_1_events/($field)"| split row "\n" | skip 2 | str join "" | split words | into int
    {
        field: $field,
        count: ($data | length),
        mean: ($data | math avg),
        std_dev: ($data | math stddev),
        max: ($data | math max),
        min: ($data | math min),
        increasing: ($data | window 2 | all {|x| ($x | get 0) <= ($x | get 1) })
    }
}

export def analyse_test_file [path: string] {
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
    {"Num Frames": $num_frames, "Num Events": $num_events} | print

    assert equal $num_events ($detector_1_events.datatype | get 2) "event_time_offset"
    assert equal $num_events ($detector_1_events.datatype | get 7) "pulse_height"

    assert equal $num_frames ($detector_1_events.datatype | get 3) "event_time_zero"
    assert equal $num_frames ($detector_1_events.datatype | get 4) "frame_complete"
    assert equal $num_frames ($detector_1_events.datatype | get 5) "frame_number"
    assert equal $num_frames ($detector_1_events.datatype | get 6) "period_number"
    assert equal $num_frames ($detector_1_events.datatype | get 8) "running"
    assert equal $num_frames ($detector_1_events.datatype | get 9) "veto_flags"

    #h5ls -d $"($path)/raw_data_1/detector_1_events/event_id"| split row "\n" | skip 2 | str join "" | split words | into int
    #    | histogram
    #    | sort-by "value"
    #    | table --index false --abbreviated 7
    #    | print
    [
        (summary_stats $path "event_id")
        (summary_stats $path "event_time_zero")
        (summary_stats $path "event_time_offset")
        (summary_stats $path "pulse_height")
        (summary_stats $path "frame_number")
    ] | table --index false | print
    
    #h5ls -d $"($path)/raw_data_1/detector_1_events/pulse_height"| split row "\n" | skip 2 | str join "" | split words | into int
    #    | histogram | print
    
    "Analysing 'runlog'" | print_heading $SUBSUBHEADING_COLOUR
    let runlog = h5ls $"($path)/raw_data_1/runlog" | split row "\n" | split column -c " " "path" "type" "datatype"
    if $runlog == [{}] {
        "Runlog empty" | print
    } else {
        for rl in $runlog {
            $"Runlog: ($rl.path)" | print_heading $SUBSUBSUBHEADING_COLOUR
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
        for sl in $selog {
            $"Selog: ($sl.path)" | print_heading $SUBSUBSUBHEADING_COLOUR
            #let this = h5ls $"($path)/raw_data_1/selog/($sl.path)/value_log" | split row "\n" | split column -c " " "path" "type" "datatype"
            let time = h5ls -d $"($path)/raw_data_1/selog/($sl.path)/value_log/time"| split row "\n" | skip 2 | str join "" | str trim -c " " | split row ", "
            let value = h5ls -d $"($path)/raw_data_1/selog/($sl.path)/value_log/value"| split row "\n" | skip 2 | str join "" | str trim -c " " | split row ", " | str trim -c '"'
            assert equal ($time | length) ($value | length)
            [["time", "value"]] | append ($time | zip $value) | each { { 0: $in.0, 1: $in.1 } } | headers | print
            #h5ls -d $"($path)/raw_data_1/runlog/($rl.path)/value" | str replace "\n" " " | print
#            $time | print
#            $value | print
        }
    }
}
