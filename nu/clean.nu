use ./prelude.nu 'print heading'

let settings: record = open "settings.json"

let broker_component = $settings.broker.nexus_writer
let pipeline_component = $settings.pipeline.nexus_writer

# Subdirectory
let subdir = $broker_component.subdirectory #if $instance_settings.new_broker_subdir? == null {
    
#} else {
#    $instance_settings.new_broker_subdir
#}

let local_path = [$pipeline_component.paths.nexus_output, $subdir] | str join "/"
let archive_path = [$pipeline_component.paths.nexus_archive, $subdir] | str join "/"

print heading "Removing Nexus Files"
#print $"archive path: ($wd)/($archive_path)"
#print $"local path: ($wd)/($local_path)"

def remove_nxs_file [] : table -> nothing {
    $in | where type == file | where { $in.name | str ends-with ".nxs" } | each { rm -v $in.name }
}

ls $"($local_path)" | remove_nxs_file
ls $"($local_path)/completed" | remove_nxs_file
ls $"($archive_path)" | remove_nxs_file