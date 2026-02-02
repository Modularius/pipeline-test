use ./prelude.nu [print_heading, HEADING_COLOUR, SUBHEADING_COLOUR]
use ./args.nu ['build_args trace_to_events', 'build_args digitiser_aggregator', 'build_args nexus_writer']
use ./settings.nu components

def spawn_component_on_host [settings: record, comp: string, args: list<string>] {
    $"Spawning component ($comp) in background" | print_heading $SUBHEADING_COLOUR
    print ($args | str join " ")
    job spawn {
        let prog = ($components | get $comp).execution_path
        with-env $settings.global_env_vars { ^$prog ...$args o+e> $"output.($comp)" }
    }
}

def get_container_env_vars [comp: string, args: list<string>] : nothing -> record {
    let component = $components | get $comp
    {
        $component.image_env_vars.image: $component.container_image,
        $component.image_env_vars.obvs_port: $component.observability.obsv_address,
        $component.image_env_vars.args: $"[($args | str join ',')]",
    }
}

export def deploy_pipeline_closures [settings: record, components: string] : nothing -> closure {
    match $components {
        host => {|instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            "Running Host Pipeline" | print_heading $HEADING_COLOUR

            if not ($instance_settings.no_trace_to_events? | default false) {
                spawn_component_on_host $settings "trace_to_events"       (build_args trace_to_events $settings $instance_settings)
            }
            if not ($instance_settings.no_digitiser_aggregator? | default false) {
                spawn_component_on_host $settings "digitiser_aggregator"  (build_args digitiser_aggregator $settings $instance_settings)
            }
            if not ($instance_settings.no_nexus_writer? | default false) {
                spawn_component_on_host $settings "nexus_writer"          (build_args nexus_writer $settings $instance_settings)
            }
        },
        container => {|instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            "Running Containerised Pipeline" | print_heading $HEADING_COLOUR

            let env_vars = (get_container_env_vars "trace_to_events"        (build_args trace_to_events $settings $instance_settings))
                    | merge     (get_container_env_vars "digitiser_aggregator"   (build_args digitiser_aggregator $settings $instance_settings))
                    | merge     (get_container_env_vars "nexus_writer"           (build_args nexus_writer $settings $instance_settings))
                    | merge $settings.global_env_vars
            with-env $env_vars {
                cat Compose/pipeline.template.yml | envsubst | save -f "Compose/pipeline.yml"
                podman-compose -f Compose/pipeline.yml -p "local" --profile all up -d | print
            }
        }
    }
}
