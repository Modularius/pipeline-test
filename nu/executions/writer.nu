use ../build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, run_writer: closure, kill_pipeline: closure>|
            "Running Trace Writer" | print_title

            #do $controls.run_saver $"Output/traces" "my_trace.h5" {};

            do $controls.run_writer $"archive/traces" "trace-proto4.h5" {
            };
        },
        "new_sub_dir": {|| null }
    }
}