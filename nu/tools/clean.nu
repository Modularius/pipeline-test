use ./../build/prelude.nu print_title
use ./../build/settings.nu SETTINGS_PATH
use ../../executions/closures.nu execution

let settings: record = open $SETTINGS_PATH


let broker_component = $settings.broker.nexus_writer
let pipeline_component = $settings.pipeline.nexus_writer

let subdir_closures = {
    benchmark: { new_subdir },
    tests: { new_subdir },
}

def 'main' [execution: string, clean_archive?: bool] {
    let clean_archive = $clean_archive | default false
    # Subdirectory
    let execution = execution $settings $execution
    let subdir = do ($execution | get "new_sub_dir") | default $broker_component.subdirectory

    let local_path = [$pipeline_component.paths.nexus_output, $subdir] | str join "/"

    "Removing Nexus Files" | print_title

    def remove_nxs_file [] : table -> nothing {
        $in | where type == file | where { $in.name | str ends-with ".nxs" } | each { rm -v $in.name }
    }

    ls $"($local_path)" | remove_nxs_file
    ls $"($local_path)/completed" | remove_nxs_file
    if $clean_archive {
        let archive_path = [$pipeline_component.paths.nexus_archive, $subdir] | str join "/"
        ls $"($archive_path)" | remove_nxs_file
    }
}