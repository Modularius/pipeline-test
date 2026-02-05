use ../build/prelude.nu print_title
use ../build/prelude.nu [print_heading, HEADING_COLOUR, SUBHEADING_COLOUR]
use ../build/args.nu ['build_args trace_to_events', 'build_args digitiser_aggregator', 'build_args nexus_writer', 'build_args simulator', 'build_args reader']
use ../../settings.nu components

def get_container_env_vars [comp: string, args: list<string>] : nothing -> record {
    let component = $components | get $comp
    {
        $component.image_env_vars.image: $component.container_image,
        $component.image_env_vars.obvs_port: $component.observability.obsv_address,
        $component.image_env_vars.args: $"[($args | str join ',')]",
    }
}

export def select_container [settings: record] : nothing -> record<deploy_pipeline:closure, kill_pipeline:closure, run_simulator:closure, run_reader:closure> {
    {
        "deploy_pipeline": {|instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            "Running Containerised Pipeline" | print_heading $HEADING_COLOUR

            let env_vars = (get_container_env_vars "trace_to_events"        (build_args trace_to_events $settings $instance_settings))
                    | merge     (get_container_env_vars "digitiser_aggregator"   (build_args digitiser_aggregator $settings $instance_settings))
                    | merge     (get_container_env_vars "nexus_writer"           (build_args nexus_writer $settings $instance_settings))
                    | merge $settings.global_env_vars
            with-env $env_vars {
                cat Compose/pipeline.template.yml | envsubst | save -f "Compose/pipeline.yml"
                podman-compose -f Compose/pipeline.yml -p $settings.broker.pipeline_name --profile all up -d | print
            }
        },
        "kill_pipeline": {||
            "Killing all pipeline containers" | print_title
            podman-compose -f Compose/pipeline.yml -p $settings.broker.pipeline_name --profile all down | print
            podman-compose -f Compose/simulator.yml -p $settings.broker.pipeline_name down | print
        },
        "run_simulator": {|source: string, envs: record, instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            "Beginning Simulation (in Container)" | print_heading $HEADING_COLOUR
            let args = build_args simulator $settings ($instance_settings | default {}) $source
            with-env ($envs | merge $settings.global_env_vars | merge (get_container_env_vars "simulator" $args)) {
                cat Compose/simulator.template.yml | envsubst | save -f "Compose/simulator.yml"
                podman-compose -f Compose/simulator.yml -p "local" up -d | print
            }
        },
        "run_reader": {|file_path: string, instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            
            "Beginning File Reader (on Host)" | print_heading $HEADING_COLOUR
            let args = build_args reader $settings ($instance_settings | default {}) $file_path
            with-env $settings.global_env_vars {
                print ($args | str join " ")
                ^$components.reader.execution_path ...$args | print
            }
        }
    }
}