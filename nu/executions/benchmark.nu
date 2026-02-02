use ../build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]

### This indicates that we do not change the default nexus file subdirectory.
export def new_subdir [] : nothing -> oneof<string,nothing> { null }

export def main [settings: record, deploy_pipeline: closure, run_simulator: closure, kill_pipeline: closure] {
    "Running Benchmark Execution" | print_title

    let pipeline_and_simulation = {|namespace: string, simulation: string, sim_env_vars: record|
        do $deploy_pipeline {new_namespace: $namespace, "suppress_archive": true}; sleep 1sec

        do $run_simulator $"Simulations/Benchmarks/($simulation).json" $sim_env_vars { new_namespace: $namespace }; sleep 1sec

        $sim_env_vars | get "RUN_NAME" | wait_until_run_completed $settings
        
        do $kill_pipeline; sleep 1sec

        #nu ./nu/clean.nu "benchmark"; sleep 1sec
    }

    do $pipeline_and_simulation "benchmark4" "timing" {TIME_BINS: 25000, RUN_NAME: "Benchmarking_Run", LAST_FRAME: 500, LAST_DIGITISER: 7 NUM_DIGITISERS: 8 }
}