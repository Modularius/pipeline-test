use ./build/prelude.nu print_title
use ./executions/benchmark.nu new_subdir

let settings: record = open "settings.json"

let broker_component = $settings.broker.nexus_writer
let pipeline_component = $settings.pipeline.nexus_writer

let subdir_closures = {
    benchmark: { new_subdir },
    tests: { new_subdir },
}

def 'main' [execution: string] {
    # Subdirectory
    let subdir = do ($subdir_closures | get $execution) | default $broker_component.subdirectory

    let local_path = [$pipeline_component.paths.nexus_output, $subdir] | str join "/"
    let archive_path = [$pipeline_component.paths.nexus_archive, $subdir] | str join "/"

    "Removing Nexus Files" | print_title

    def remove_nxs_file [] : table -> nothing {
        $in | where type == file | where { $in.name | str ends-with ".nxs" } | each { rm -v $in.name }
    }

    ls $"($local_path)" | remove_nxs_file
    ls $"($local_path)/completed" | remove_nxs_file
    ls $"($archive_path)" | remove_nxs_file
}

export def 'main topics' [] {
    podman exec kafka rpk topic delete $settings.broker.topics.traces $settings.broker.topics.dat-events $settings.broker.topics.frame-events | print
    #podman exec kafka rpk topic create $settings.broker.topics.traces $settings.broker.topics.dat-events $settings.broker.topics.frame-events | print
}