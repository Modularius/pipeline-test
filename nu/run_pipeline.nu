use ./prelude.nu print_heading
use ./args.nu ['build_args trace_to_events', 'build_args digitiser_aggregator', 'build_args nexus_writer', 'build_args simulator']
use ./settings.nu [build_rust_log_env, build_otel_level_env, constants, components]
use ./executions/benchmark.nu
use ./executions/tests.nu

let settings: record = open "settings.json"

const HEADING_COLOUR = "blue"
const SUBHEADING_COLOUR = "yellow"

let global_env_vars = {
    "NO_COLOR": ($constants.no_color_env | into string),
    "RUST_LOG": (build_rust_log_env),
    "OTEL_LEVEL": (build_otel_level_env),
}

def spawn_component_on_host [comp: string, args: list<string>] {
    $"Spawning component ($comp) in background" | print_heading $SUBHEADING_COLOUR
    print ($args | str join " ")
    job spawn {
        let prog = ($components | get $comp).execution_path
        with-env $global_env_vars { ^$prog ...$args o+e> $"output.($comp)" }
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

let deploy_pipeline_closures = {
    host: {|instance_settings?: record|
        let instance_settings = ($instance_settings | default {})

        "Running Host Pipeline" | print_heading $HEADING_COLOUR

        spawn_component_on_host "trace_to_events"       (build_args trace_to_events $settings $instance_settings)
        spawn_component_on_host "digitiser_aggregator"  (build_args digitiser_aggregator $settings $instance_settings)
        spawn_component_on_host "nexus_writer"          (build_args nexus_writer $settings $instance_settings)
    },
    container: {|instance_settings?: record|
        let instance_settings = ($instance_settings | default {})
        
        "Running Containerised Pipeline" | print_heading $HEADING_COLOUR

        let env_vars = (get_container_env_vars "trace_to_events"        (build_args trace_to_events $settings $instance_settings))
                | merge     (get_container_env_vars "digitiser_aggregator"   (build_args digitiser_aggregator $settings $instance_settings))
                | merge     (get_container_env_vars "nexus_writer"           (build_args nexus_writer $settings $instance_settings))
                | merge $global_env_vars
        with-env $env_vars {
            cat Compose/pipeline.template.yml | envsubst | save -f "Compose/pipeline.yml"
            podman-compose -f Compose/pipeline.yml -p "local" --profile all up -d | print
        }
    }
}

let simulator_closure = {|suffix: string, clo: closure, source: string, envs: record, instance_settings?: record|
    $"Beginning Simulation ($suffix)" | print_heading $SUBHEADING_COLOUR
    let args = build_args simulator $settings ($instance_settings | default {}) $source
    with-env ($envs | merge $global_env_vars) {
        do $clo $args
    }
    "Simulator Complete" | print_heading $SUBHEADING_COLOUR
}

let run_simulator_closures = {
    host: {|source: string, envs: record, instance_settings?: record|
        do $simulator_closure "on Host" {|args: list<string>|
            print ($args | str join " ")
            ^$components.simulator.execution_path ...$args | print
        } $source $envs $instance_settings
    }
    all_container: {|source: string, envs: record, instance_settings?: record|
        do $simulator_closure "in Container" {|args: list<string>|
            with-env (get_container_env_vars "simulator" $args) {
                cat Compose/simulator.template.yml | envsubst | save -f "Compose/simulator.yml"
                podman-compose -f Compose/simulator.yml -p "local" up -d | print
            }
        } $source $envs $instance_settings
    }
    container: {|source: string, envs: record, instance_settings?: record|
        "Beginning Simulation on Host" | print_heading $SUBHEADING_COLOUR

        let args = build_args simulator $settings ($instance_settings | default {}) $source
        with-env $envs {
            print ($args | str join " ")
            ^$components.simulator.execution_path ...$args | print
        }
        
        "Simulator Complete" | print_heading $SUBHEADING_COLOUR
    }
}

let execution_closures = {
    benchmark: {|deploy_pipeline, run_simulator, kill_pipeline| benchmark $deploy_pipeline $run_simulator $kill_pipeline },
    tests: {|deploy_pipeline, run_simulator, kill_pipeline| tests $deploy_pipeline $run_simulator $kill_pipeline },
}



def main [mode: string, execution: string] {
    let deploy_pipeline = $deploy_pipeline_closures | get $mode
    let run_simulator = $run_simulator_closures | get $mode

    do ($execution_closures | get $execution) $deploy_pipeline $run_simulator { nu ./nu/kill.nu $mode }
}