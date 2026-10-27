use ../build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            "Running Simulator Execution" | print_title

            #let path = "Simulations/Tests/SanityChecking/one_run.json";
            let path = "Simulations/Tests/aborted_run.json";

            do $controls.run_simulator $path {
                
                TIME_BINS: 30000,
                MAX_NOISE: 3,
                RUN_NAME: "MUSR00000001",
                LAST_FRAME: 100,
                PULSE_MEAN_LIFETIME: 2200,
                NUM_PULSES: 10,
                LAST_DIGITISER: 7 NUM_DIGITISERS: 8
            };
        },
        "new_sub_dir": {|| null }
    }
}