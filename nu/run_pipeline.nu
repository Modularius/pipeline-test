use ./prelude.nu 'print heading'
use ./settings.nu 'build args trace_to_events'
use ./settings.nu 'build args digitiser_aggregator'
use ./settings.nu 'build args nexus_writer'
use ./settings.nu 'build args simulator'
use ./settings.nu build_rust_log_env
use ./settings.nu build_otel_level_env


let settings: record = open "settings.json"

def spawn_component [comp: string, args: list<string>] {
    print heading $"Spawning component ($comp) in background"
    print ($args | str join " ")
    job spawn {
        let prog = ($settings.constants.components | get $comp).execution_path
        ^$prog ...$args o+e> (["error", $comp] | str join ".")
    }
}

def execute_pipeline_on_host [] {
    spawn_component "trace_to_events"       (build args trace_to_events $settings {})
    spawn_component "digitiser_aggregator"  (build args digitiser_aggregator $settings {})
    spawn_component "nexus_writer"          (build args nexus_writer $settings {})
}

def get_container_env_vars [comp: string, args: list<string>] : nothing -> record {
    let component = $settings.constants.components | get $comp
    {
        $component.image_env_vars.image: $component.container_image,
        $component.image_env_vars.obvs_port: $component.observability.obsv_address,
        $component.image_env_vars.args: $"[($args | str join ',')]",
    }
}

def execute_pipeline_containers [] {
    let env_vars = (get_container_env_vars trace_to_events (build args trace_to_events $settings {}))
            | merge (get_container_env_vars digitiser_aggregator (build args digitiser_aggregator $settings {}))
            | merge (get_container_env_vars nexus_writer (build args nexus_writer $settings {}))
            | merge {
                "NO_COLOR": ($settings.constants.no_color_env | into string),
                "RUST_LOG": (build_rust_log_env "info" $settings.constants.components),
                "OTEL_LEVEL": (build_otel_level_env "info" $settings.constants.components),
            }
    with-env $env_vars {
        cat Compose/pipeline.template.yml | envsubst | save -f "Compose/pipeline.yml"
        #cat Compose/pipeline.template.yml | envsubst > Compose/pipeline.yml;
        #podman-compose -f Compose/pipeline.yml -p "local" --profile all up -d
    }
}

execute_pipeline_containers

sleep 1sec

print heading "Beginning Simulation"
let args = build args simulator $settings {} "Simulations/Benchmarks/timing.json"
with-env { RUN_NAME: "New_Run" } {
    print ($args | str join " ")
    ^$settings.constants.components.simulator.execution_path ...$args
}
print heading "Simulator Complete"

print "Type anything to quit"
let _ = input