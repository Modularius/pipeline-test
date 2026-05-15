use ../build/prelude.nu [print_title, print_heading, HEADING_COLOUR, SUBHEADING_COLOUR, get_nexus_local_path, get_nexus_archive_path]
use ../build/args.nu ['build_args trace_to_events', 'build_args digitiser_aggregator', 'build_args nexus_writer', 'build_args simulator', 'build_args reader']

def get_container_env_vars [component: record, args: list<string>] : nothing -> record {
    {
        $component.image_env_vars.image: $component.container_image,
        $component.image_env_vars.obvs_port: $component.observability,
        $component.image_env_vars.args: $"[($args | str join ',')]",
    }
}

def custom_settings_with_affix [number: int, affix : string] : record -> record {
    $in | update components.digitiser_aggregator.observability.obsv_address ([127.0.0.1:2902, ($number | into string)] | str join "")
        | update components.nexus_writer.observability.obsv_address ([127.0.0.1:2903, ($number | into string)] | str join "")
        | update broker.pipeline_name ([$in.broker.pipeline_name, $affix] | str join "_")
        | update broker.topics.dat_event ([$in.broker.topics.dat_event, $affix] | str join "_")
        | update broker.topics.frame_event ([$in.broker.topics.frame_event, $affix] | str join "_")
        | update broker.consumer_groups.digitiser_aggregator ([$in.broker.consumer_groups.digitiser_aggregator, $affix] | str join "_")
        | update broker.consumer_groups.nexus_writer ([$in.broker.consumer_groups.nexus_writer, $affix] | str join "_")
        | update broker.nexus_writer.subdirectory ([$in.broker.nexus_writer.subdirectory, $affix] | str join "/")
}

const detector = "detector"
const DETECTOR = "DETECTOR"
const true = "true"
const TRUE = "TRUE"

export def select_param_space [settings: record] : nothing -> record<deploy_pipeline:closure, kill_pipeline:closure, run_simulator:closure, run_reader:closure> {
    {
        "deploy_pipeline": {|instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            "Running Containerised Pipeline" | print_heading $HEADING_COLOUR

            let detector_settings = $settings | custom_settings_with_affix 0 $detector
            let true_settings = $settings | custom_settings_with_affix 1 $true

            let nexus_path_overwrites = {
                new_local_path: "/local",
                new_archive_path: "/archive"
            }
            let detector_components = $settings.components
             | update digitiser_aggregator.image_env_vars.args ([$settings.components.digitiser_aggregator.image_env_vars.args , $DETECTOR] | str join "_")
             | update nexus_writer.image_env_vars.args ([$settings.components.nexus_writer.image_env_vars.args , $DETECTOR] | str join "_")
            let true_components = $settings.components
             | update digitiser_aggregator.image_env_vars.args ([$settings.components.digitiser_aggregator.image_env_vars.args , $TRUE] | str join "_")
             | update nexus_writer.image_env_vars.args ([$settings.components.nexus_writer.image_env_vars.args , $TRUE] | str join "_")

            let env_vars = (get_container_env_vars $detector_components.trace_to_events      (build_args trace_to_events $detector_settings $instance_settings))
                    | merge     (get_container_env_vars $detector_components.digitiser_aggregator (build_args digitiser_aggregator $detector_settings $instance_settings))
                    | merge     (get_container_env_vars $true_components.digitiser_aggregator     (build_args digitiser_aggregator $true_settings $instance_settings))
                    | merge     (get_container_env_vars $detector_components.nexus_writer         (build_args nexus_writer $detector_settings ($instance_settings | merge $nexus_path_overwrites) ))
                    | merge     (get_container_env_vars $true_components.nexus_writer             (build_args nexus_writer $true_settings ($instance_settings | merge $nexus_path_overwrites) ))
                    | merge $settings.global_env_vars
                    | merge {
                        (["NEXUS_OUTPUT_PATH", $DETECTOR] | str join "_"): (get_nexus_local_path $detector_settings $instance_settings),
                        (["NEXUS_OUTPUT_PATH", $TRUE] | str join "_"): (get_nexus_local_path $true_settings $instance_settings)
                    }

            with-env $env_vars {
                cat Compose/param_space/pipeline.template.yml | envsubst | save -f "Compose/param_space/pipeline.yml"
                podman-compose -f Compose/param_space/pipeline.yml -p $settings.broker.pipeline_name up -d | print
            }
        },
        "kill_pipeline": {||
            "Killing all pipeline containers" | print_title
            podman-compose -f Compose/param_space/pipeline.yml -p $settings.broker.pipeline_name --profile all down | print
            pkill -e --signal SIGINT simulator | print
        },
        "run_simulator": {|source: string, envs: record, instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            
            "Beginning Simulation (on Host)" | print_heading $HEADING_COLOUR
            let args = build_args simulator $settings ($instance_settings | default {}) $source
            print ($args | str join " ")
            let prog = $settings.components.simulator.execution_path
            with-env ($envs | merge $settings.global_env_vars) {
                ^$prog ...$args o+e> $"output.simulator"
            }
        },
        "run_reader": {|file_path: string, instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            
            "Beginning File Reader (on Host)" | print_heading $HEADING_COLOUR
            let args = build_args reader $settings ($instance_settings | default {}) $file_path
            with-env $settings.global_env_vars {
                print ($args | str join " ")
                ^$settings.components.reader.execution_path ...$args | print
            }
        }
    }
}