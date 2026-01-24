use ../prelude.nu 'print heading'

### This indicates that we do not change the default nexus file subdirectory.
export def new_subdir [] : nothing -> oneof<string,nothing> { null }

export def main [deploy_pipeline: closure, run_simulator: closure, kill_pipeline: closure] {
    print heading "Running Benchmark Execution"

    let pipeline_and_simulation = {|namespace: string, simulation: string, sim_env_vars: record|
        do $deploy_pipeline {new_namespace: $namespace, "suppress_archive": true}; sleep 1sec

        do $run_simulator $"Simulations/Benchmarks/($simulation).json" $sim_env_vars { new_namespace: $namespace }; sleep 1sec

        let run_name = ($sim_env_vars | get "RUN_NAME")
        let completed_path = $"Output/local/completed/($run_name).nxs"
        while not ($completed_path | path exists) { sleep 1sec }
        let path = $"Output/local/($run_name).nxs"
        while ($path | path exists) { sleep 1sec }

        do $kill_pipeline; sleep 1sec

        #nu ./nu/clean.nu "benchmark"; sleep 1sec
    }

    do $pipeline_and_simulation "test_3" "timing" {TIME_BINS: 10000, RUN_NAME: "New_Run" }
}