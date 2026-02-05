use ../nu/build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]

### This indicates that we do not change the default nexus file subdirectory.
export def new_subdir [] : nothing -> oneof<string,nothing> { null }

export def main [settings: record, controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>] {
    "Running Reader Execution" | print_title

    let pipeline_and_reader = {|namespace: string, file_name: string|
        do $controls.deploy_pipeline {new_namespace: $namespace, "suppress_archive": true, no_digitiser_aggregator: true, no_nexus_writer: true}; sleep 2sec

        do $controls.run_reader $"../trace_files/($file_name)" { new_namespace: $namespace, number_of_trace_events: 100 }; sleep 1sec

        #$sim_env_vars | get "RUN_NAME" | wait_until_run_completed $settings
        
        #do $kill_pipeline; sleep 1sec

        #nu ./nu/clean.nu "benchmark"; sleep 1sec
    }

    do $pipeline_and_reader "reader_1" "MuSR_A27_B28_C29_D30_Apr2021_Ag_ZF_InstDeg_Slit60_short.traces"
}