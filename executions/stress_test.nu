use ../nu/build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            "Running Stress Test Execution" | print_title

            let pipeline_and_simulation = {|namespace: string, simulation: string, sim_env_vars: record|
                do $controls.deploy_pipeline {new_namespace: $namespace, "suppress_archive": true, no_trace_to_events: false, no_digitiser_aggregator: false, no_nexus_writer: false}; sleep 2sec

                do $controls.run_simulator $"Simulations/($simulation).json" $sim_env_vars { new_namespace: $namespace }; sleep 1sec

                $sim_env_vars | get "RUN_NAME" | wait_until_run_completed $settings
                
                #do $controls.kill_pipeline; sleep 1sec

                #nu ./nu/clean.nu "benchmark"; sleep 1sec
            }
            do $pipeline_and_simulation "Benchmark2" "noisy" {
                RUN_NAME: "Temp",
                TIME_BINS: 30000,
                MAX_NOISE: 4500,
                LAST_FRAME: 0,
                NUM_DIGITISERS: 8,
                LAST_DIGITISER: 7,
            }
        },
        "new_sub_dir": {|| ["local"] }
    }
}