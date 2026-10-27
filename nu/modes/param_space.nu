use ../build/prelude.nu [print_title, print_heading, HEADING_COLOUR, SUBHEADING_COLOUR, get_nexus_local_path, get_nexus_archive_path]
use ../build/args.nu ['build_args trace_to_events', 'build_args digitiser_aggregator', 'build_args nexus_writer', 'build_args simulator', 'build_args reader', 'build_args hdf5_reader', 'build_args analyser']

def get_container_env_vars [component: record, args: list<string>] : nothing -> record {
    {
        $component.image_env_vars.image: $component.container_image,
        $component.image_env_vars.obvs_port: $component.observability,
        $component.image_env_vars.args: $"[($args | str join ',')]",
    }
}

def custom_settings_with_number [number: int] : record -> record {
    $in | update components.digitiser_aggregator.observability.obsv_address ([127.0.0.1:2902, ($number | into string)] | str join "")
        | update components.nexus_writer.observability.obsv_address ([127.0.0.1:2903, ($number | into string)] | str join "")
}

def custom_settings_with_affix [affix : string] : record -> record {
    $in | update broker.pipeline_name ([$in.broker.pipeline_name, $affix] | str join "_")
        | update broker.topics.dat_event ([$in.broker.topics.dat_event, $affix] | str join "_")
        | update broker.topics.frame_event ([$in.broker.topics.frame_event, $affix] | str join "_")
        | update broker.consumer_groups.digitiser_aggregator ([$in.broker.consumer_groups.digitiser_aggregator, $affix] | str join "_")
        | update broker.consumer_groups.nexus_writer ([$in.broker.consumer_groups.nexus_writer, $affix] | str join "_")
        | update broker.nexus_writer.subdirectory ([$in.broker.nexus_writer.subdirectory, $affix] | str join "/")
}

def spawn_component_on_host [settings: record, comp: string, args: list<string>] : nothing -> int {
    $"Spawning component ($comp) in background" | print_heading $SUBHEADING_COLOUR
    print ($args | str join " ")
    job spawn {
        let prog = ($settings.components | get $comp).execution_path
        with-env $settings.global_env_vars {
            ^$prog ...$args o+e> $"logs/output.($comp)"
        }
    }
}

const detector = "detector"
const DETECTOR = "DETECTOR"
const true = "true"
const TRUE = "TRUE"

export def select_param_space [settings: record] : nothing -> record<deploy_pipeline:closure, kill_pipeline:closure, run_simulator:closure, run_reader: closure, run_hdf5_reader:closure, run_analyser: closure> {
    {
        "deploy_pipeline": {|instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            "Running Containerised Pipeline" | print_heading $HEADING_COLOUR
            
            #let detector_settings = $settings | custom_settings_with_number 0
            #let true_settings = $settings | custom_settings_with_number 1 | custom_settings_with_affix $true

            let env_vars = (get_container_env_vars $settings.components.trace_to_events      (build_args trace_to_events $settings $instance_settings))
                | merge $settings.global_env_vars

            with-env $env_vars {
                cat Compose/param_space/pipeline.template.yml | envsubst | save -f "Compose/param_space/pipeline.yml"
                podman-compose -f Compose/param_space/pipeline.yml -p $settings.broker.pipeline_name up -d | print
            }
        },
        "kill_pipeline": {||
            "Killing all pipeline containers" | print_title
            podman-compose -f Compose/param_space/pipeline.yml -p $settings.broker.pipeline_name --profile all down | print
        },
        "run_simulator": {|source: string, envs: record, instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            
            "Beginning Simulation (on Host)" | print_heading $HEADING_COLOUR
            let args = build_args simulator $settings ($instance_settings | default {}) $source
            print ($args | str join " ")
            let prog = $settings.components.simulator.execution_path
            with-env ($envs | merge $settings.global_env_vars) {
                ^$prog ...$args o+e> "logs/output.simulator"
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
        },
        "run_hdf5_reader": {|file_path: string, read_seq: string, instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            
            "Beginning HDF5 File Reader (on Host)" | print_heading $HEADING_COLOUR
            let args = build_args hdf5_reader $settings ($instance_settings | default {}) $file_path $read_seq
            print ($args | str join " ")
            let prog = $settings.components.reader.execution_path
            with-env $settings.global_env_vars {
                ^$prog ...$args o+e> "logs/output.reader"
            }
        },
        "run_analyser": {|chart_output: string, analyser_settings: string, instance_settings?: record|
            "Beginning Events Analyser (in Container)" | print_heading $HEADING_COLOUR
            let args = build_args analyser $settings "/analysis_settings.json" "/chart_output" ($instance_settings | default {})
            
            let env_vars = (get_container_env_vars $settings.components.analyser      $args)
                | merge {
                    "CHART_OUTPUT_PATH": $chart_output,
                    "ANALYSIS_SETTINGS_PATH": $analyser_settings
                    }
                | merge $settings.global_env_vars

            with-env $env_vars {
                #cat Compose/param_space/analyser.template.yml | envsubst | save -f "Compose/param_space/analyser.yml"
                #podman-compose -f Compose/param_space/analyser.yml up -d | print
            }
            
            let host_args = build_args analyser $settings $analyser_settings $chart_output ($instance_settings | default {})
            spawn_component_on_host $settings "analyser" $host_args

        },
        "kill_analyser": {||
            "Killing Events Analyser container" | print_title
            podman-compose -f Compose/param_space/analyser.yml down | print
        },
    }
}