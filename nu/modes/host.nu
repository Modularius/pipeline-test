use ../build/prelude.nu print_title
use ../build/prelude.nu [print_heading, HEADING_COLOUR, SUBHEADING_COLOUR]
use ../build/args.nu ['build_args trace_to_events', 'build_args digitiser_aggregator', 'build_args nexus_writer', 'build_args simulator']
use ../build/settings.nu components

def spawn_component_on_host [settings: record, comp: string, args: list<string>] {
    $"Spawning component ($comp) in background" | print_heading $SUBHEADING_COLOUR
    print ($args | str join " ")
    job spawn {
        let prog = ($components | get $comp).execution_path
        with-env $settings.global_env_vars { ^$prog ...$args o+e> $"output.($comp)" }
    }
}

export def select_host [settings: record] : nothing -> record<deploy:closure, kill:closure, run_simulator:closure> {
    {
        "deploy": {|instance_settings?: record|
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
        "kill": {
            "Killing all pipeline host processes" | print_title
            let components = [ "trace_to_events", "digitiser_aggregator", "nexus_writer", "simulator" ]
            for comp in $components {
                let name = ($settings.components | get $comp).process_name
                "pkill --signal SIGINT " ++ $name | print
                pkill -e --signal SIGINT $name | print
            }
        },
        "run_simulator": {|source: string, envs: record, instance_settings?: record|
            let instance_settings = ($instance_settings | default {})
            
            "Beginning Simulation (on Host)" | print_heading $HEADING_COLOUR
            let args = build_args simulator $settings ($instance_settings | default {}) $source
            with-env ($envs | merge $settings.global_env_vars) {
                print ($args | str join " ")
                ^$components.simulator.execution_path ...$args | print
            }
        }
    }
}