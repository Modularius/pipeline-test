use ../nu/build/prelude.nu [print_heading, print_title, HEADING_COLOUR, SUBHEADING_COLOUR, SUBSUBHEADING_COLOUR, wait_until_runs_completed]
use ../nu/build/analysis.nu analyse_test_file
use std/assert

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            "Running Tests Execution" | print_title

            let simulation_and_analysis = {|simulation: string, sim_env_vars: record, run_names: list<string>|
                do $controls.run_simulator $"Simulations/Tests/($simulation).json" $sim_env_vars {}; sleep 1sec

                let completed_paths = $run_names | wait_until_runs_completed $settings
                for completed_path in $completed_paths {
                    analyse_test_file $completed_path
                }
            }
            
            do $controls.deploy_pipeline {"suppress_archive": true}; sleep 1sec

            do $simulation_and_analysis "SanityChecking/one_run" {
                RUN_NAME: "SC_SingleRun", TIME_BINS: 10000,
                LAST_FRAME: 1, NUM_DIGITISERS: 8, LAST_DIGITISER: 7,
                NUM_PULSES: 100, PULSE_MEAN_LIFETIME: 1000
            } ["SC_SingleRun"]

            do $simulation_and_analysis "SanityChecking/five_runs" {
                RUN_NAME_1: "SC_Run1of5", RUN_NAME_2: "SC_Run2of5",
                RUN_NAME_3: "SC_Run3of5", RUN_NAME_4: "SC_Run4of5",
                RUN_NAME_5: "SC_Run5of5", TIME_BINS: 10000,
                LAST_FRAME: 1, NUM_DIGITISERS: 8, LAST_DIGITISER: 7,
                NUM_PULSES: 100, PULSE_MEAN_LIFETIME: 1000
            } ["SC_Run1of5", "SC_Run2of5", "SC_Run3of5", "SC_Run4of5", "SC_Run5of5"]

            do $simulation_and_analysis "SanityChecking/two_runs_and_selogs" {
                RUN_NAME_1: "SC_Selogs_Run1of2", RUN_NAME_2: "SC_Selogs_Run2of2",
                TIME_BINS: 10000,
                LAST_FRAME: 1, NUM_DIGITISERS: 8, LAST_DIGITISER: 7,
                NUM_PULSES: 100, PULSE_MEAN_LIFETIME: 1000
            } ["SC_Selogs_Run1of2", "SC_Selogs_Run2of2"]

            do $controls.kill_pipeline
        },
        "new_sub_dir": {|| null }
    }
}