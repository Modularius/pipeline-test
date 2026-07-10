use ../build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, run_hdf5_reader: closure, run_writer: closure, kill_pipeline: closure>|
            "Running Trace Saver" | print_title

            #do $controls.run_writer $"Output/traces" "MuSR_proto_00104358.h5" {
                #use_control_topic: true,
            #};

            do $controls.run_hdf5_reader $"archive/traces/trace-proto4.h5" {
                shift_to_today: true,
                use_indices: true,
                from_index: 6577,
                to_index: 10388,
            };
        },
        "new_sub_dir": {|| null }
    }
}