use ../nu/build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]

### This indicates that we do not change the default nexus file subdirectory.
export def new_subdir [] : nothing -> oneof<string,nothing> { null }

export def main [settings: record, controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>] {
    "Running Simulator Execution" | print_title

    do $controls.run_simulator $"Simulations/Benchmarks/timing.json" {
        TIME_BINS: 30000,
        MAX_NOISE: 3,
        RUN_NAME: "Benchmark Run",
        LAST_FRAME: 100,
        LAST_DIGITISER: 7 NUM_DIGITISERS: 8
    };
}