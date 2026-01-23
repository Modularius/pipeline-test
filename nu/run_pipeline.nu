use ./prelude.nu 'print heading'
use ./args.nu ['build_args trace_to_events', 'build_args digitiser_aggregator', 'build_args nexus_writer', 'build_args simulator']
use ./settings.nu [build_rust_log_env, build_otel_level_env, constants, components]
use ./executions/benchmark.nu

let settings: record = open "settings.json"

let global_env_vars = {
    "NO_COLOR": ($constants.no_color_env | into string),
    "RUST_LOG": (build_rust_log_env),
    "OTEL_LEVEL": (build_otel_level_env),
}

def spawn_component_on_host [comp: string, args: list<string>] {
    print heading $"Spawning component ($comp) in background"
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
        print heading "Running Host Pipeline"
        spawn_component_on_host "trace_to_events"       (build_args trace_to_events $settings $instance_settings)
        spawn_component_on_host "digitiser_aggregator"  (build_args digitiser_aggregator $settings $instance_settings)
        spawn_component_on_host "nexus_writer"          (build_args nexus_writer $settings $instance_settings)
    },
    container: {|instance_settings?: record|
        let instance_settings = ($instance_settings | default {})
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

let run_simulator_closures = {
    host: {|source: string, envs: record, instance_settings?: record|
        print heading "Beginning Simulation on Host"
        let args = build_args simulator $settings ($instance_settings | default {}) $source
        with-env $envs {
            print ($args | str join " ")
            ^$components.simulator.execution_path ...$args | print
        }
        print heading "Simulator Complete"
    }
    container: {|source: string, envs: record, instance_settings?: record|
        print heading "Beginning Simulation on Host"
        let args = build_args simulator $settings ($instance_settings | default {}) $source
        with-env $envs {
            print ($args | str join " ")
            ^$components.simulator.execution_path ...$args | print
        }
        print heading "Simulator Complete"
    }
}

let execution_closures = {
    benchmark: {|deploy_pipeline, run_simulator, kill_pipeline| benchmark $deploy_pipeline $run_simulator $kill_pipeline }
}



def main [mode: string, execution: string] {
    let deploy_pipeline = $deploy_pipeline_closures | get $mode
    let run_simulator = $run_simulator_closures | get $mode

    do ($execution_closures | get $execution) $deploy_pipeline  $run_simulator { nu ./nu/kill.nu $mode }
}