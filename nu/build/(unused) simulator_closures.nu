use ./prelude.nu [print_heading, HEADING_COLOUR, SUBHEADING_COLOUR]
use ./args.nu ['build_args trace_to_events', 'build_args digitiser_aggregator', 'build_args nexus_writer', 'build_args simulator']
use ./settings.nu [build_rust_log_env, build_otel_level_env, constants, components]

def simulator_closure [settings: record, suffix: string, closure: closure] : record<source: string, envs: record, instance_settings: oneof<record,nothing>> -> nothing {
    $"Beginning Simulation ($suffix)" | print_heading $HEADING_COLOUR
    let args = build_args simulator $settings ($in.instance_settings | default {}) $in.source
    with-env ($in.envs | merge $settings.global_env_vars) {
        do $closure $args
    }
}

export def run_simulator_closures [settings: record, component: string] : nothing -> closure {
    match $component {
        host => {|source: string, envs: record, instance_settings?: record|
            {source: $source, envs: $envs, instance_settings: $instance_settings} | simulator_closure $settings "on Host" {|args: list<string>|
                print ($args | str join " ")
                ^$components.simulator.execution_path ...$args | print
            }
        }
        container => {|source: string, envs: record, instance_settings?: record|
            {source: $source, envs: $envs, instance_settings: $instance_settings} | simulator_closure $settings "in Container" {|args: list<string>|
                with-env (get_container_env_vars "simulator" $args) {
                    cat Compose/simulator.template.yml | envsubst | save -f "Compose/simulator.yml"
                    podman-compose -f Compose/simulator.yml -p "local" up -d | print
                }
            }
        }
    }
}
