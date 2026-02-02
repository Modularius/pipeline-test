export const HEADING_COLOUR = "red"
export const SUBHEADING_COLOUR = "yellow"
export const SUBSUBHEADING_COLOUR = "green"
export const SUBSUBSUBHEADING_COLOUR = "blue"

export def print_title [] : string -> nothing {
    let strlen = $in | str length
    $"(ansi bo)($in
        | ansi gradient --fgstart "0xFFCBaa" --fgend "0x56D095"
    )(ansi reset)" | print
}

export def print_heading [colour: string] : string -> nothing {
    let strlen = $in | str length
    let width = match $colour {
        "red" => 2
        "yellow" => 4
        "green" => 6
        "blue" => 8
    }
    $"(ansi $colour)(ansi bo)($in
        | fill --width ($strlen + $width) --alignment "r"
    )(ansi reset)" | print
}

export def print_gradient_heading [colour: string, colour2: string] : string -> nothing {
        $"(ansi bo)($in | ansi gradient --fgstart $colour --fgend $colour2)(ansi reset)" | print
}

export def get_nexus_local_path [settings: record, instance_settings: record = {}] {
    let subdir = $instance_settings.new_broker_subdir? | default $settings.broker.nexus_writer.subdirectory
    [$settings.pipeline.nexus_writer.paths.nexus_output, $subdir] | str join "/"
}

export def get_nexus_archive_path [settings: record, instance_settings: record = {}] {
    let subdir = $instance_settings.new_broker_subdir? | default $settings.broker.nexus_writer.subdirectory
    [$settings.pipeline.nexus_writer.paths.nexus_archive, $subdir] | str join "/"
}

export def wait_until_runs_completed [settings: record, instance_settings: record = {}] : list<string> -> list<string>, string -> string {
    let local_path = get_nexus_local_path $settings $instance_settings
    let completed_paths: list<string> = $in | each {|run_name| $"($local_path)/completed/($run_name).nxs" }
    while not ($completed_paths | path exists | all {$in}) { sleep 1sec }
    let paths = $in | each {|run_name| $"($local_path)/($run_name).nxs" }
    while ($paths | path exists | any {$in}) { sleep 1sec }
    return $completed_paths
}

export def wait_until_run_completed [settings: record, instance_settings?: record] : string -> string {
    let local_path = get_nexus_local_path $settings $instance_settings
    let completed_path = $"($local_path)/completed/($in).nxs"
    while not ($completed_path | path exists) { sleep 1sec }
    let paths = $"($local_path)/($in).nxs"
    while ($paths | path exists) { sleep 1sec }
    return $completed_path
}