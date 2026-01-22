use ../prelude.nu 'print heading'

### This indicates that we do not change the default nexus file subdirectory.
export def new_subdir [] : nothing -> oneof<string,nothing> { null }

export def main [deploy_pipeline: closure, run_simulator: closure] {
    print heading "Running Benchmark Execution"

    do $deploy_pipeline {new_namespace: "test", "suppress_archive": true}
    sleep 1sec

    do $run_simulator "Simulations/Benchmarks/timing.json" { RUN_NAME: "New_Run" } {new_namespace: "test" }
}