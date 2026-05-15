use ../nu/build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            "Running Stress Test Execution" | print_title

            let pipeline_and_simulation = {|namespace: string, simulation: string, sim_env_vars: record|
                do $controls.deploy_pipeline {new_namespace: $namespace, new_subdir: "simulated_runs", "suppress_archive": false, no_trace_to_events: true, no_digitiser_aggregator: true, no_nexus_writer: false}; sleep 2sec

                do $controls.run_simulator $"Simulations/($simulation).json" $sim_env_vars { new_namespace: $namespace }; sleep 1sec

                $sim_env_vars | get "RUN_NAME" | wait_until_run_completed $settings { new_subdir: "simulated_runs" }
                
                #do $controls.kill_pipeline; sleep 1sec

                #nu ./nu/clean.nu "benchmark"; sleep 1sec
            }
            do $pipeline_and_simulation "generated" "Temp/for_anthony" {
            }

            # do $pipeline_and_simulation "generated" "Temp/for_anthony" {
            #     #RUN_NAME: "TEN_MIN_00000001", INSTR_NAME: "TEN_MIN_", LAST_FRAME: (50 * 60 * 10 - 1), LAST_SELOG: (60 * 1 - 1)
            #     #RUN_NAME: "ONE_HOUR_00000001", INSTR_NAME: "ONE_HOUR_", LAST_FRAME: (50 * 3600 * 1 - 1), LAST_SELOG: (360 * 1 - 1)
            #     #RUN_NAME: "SIX_HOUR_00000001", INSTR_NAME: "SIX_HOUR_", LAST_FRAME: (50 * 3600 * 6 - 1), LAST_SELOG: (360 * 6 - 1)
            #     #RUN_NAME: "TWELVE_HOUR_00000001", INSTR_NAME: "TWELVE_HOUR_", LAST_FRAME: (50 * 3600 * 12 - 1), LAST_SELOG: (360 * 12 - 1)
            #     #RUN_NAME: "EIGHTEEN_HOUR_00000001", INSTR_NAME: "EIGHTEEN_HOUR_", LAST_FRAME: (50 * 3600 * 18 - 1), LAST_SELOG: (360 * 18 - 1)
            #     RUN_NAME: "DAY_00000001", INSTR_NAME: "DAY_", LAST_FRAME: (50 * 3600 * 24 - 1), LAST_SELOG: (360 * 24 - 1)
            # }
        },
        "new_sub_dir": {|| ["simulated_runs"] }
    }
}