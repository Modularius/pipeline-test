use ../build/prelude.nu [print_title, SUBHEADING_COLOUR]
use ../build/analysis.nu analyse_test_file

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, run_hdf5_reader: closure, kill_pipeline: closure>|
            "Running Param Explorer Trace Reader Execution" | print_title
            let dat_event = [$settings.broker.topics.dat_event, "true"] | str join "_"

            let instance_settings =  { dat_event: $dat_event, shift_to_today: true }

            #let test_index = $settings.test_index

            let runs = [
                {
                    path: "archive/traces/trace-proto.h5",
                    from_index: 0,
                    to_index: 512
                },
                #{
                #    path: "archive/traces/trace-proto.h5",
                #    from_index: 26512,
                #    to_index: 26640
                #},
                {
                    path: "archive/traces/trace-proto2.h5",
                    from_index: 0,
                    to_index: 512
                },
                {
                    path: "archive/traces/trace-proto3.h5",
                    from_index: 0,
                    to_index: 512
                },
                #{
                #    path: "archive/traces/trace-proto3.h5",
                #    from_index: 6586
                #    to_index: 6714
                #},
                {
                    path: "archive/traces/trace-proto4.h5",
                    from_index: 0,
                    to_index: 512
                },
                #{
                #    path: "archive/traces/trace-proto4.h5",
                #    from_index: 6577
                #    to_index: 6605
                #},
                {
                    path: "archive/traces/trace-proto5.h5",
                    from_index: 0,
                    to_index: 512
                }
            ]
            $runs | each {|run|
                let instance_settings = $instance_settings | merge { use_indices: true, from_index: $run.from_index, to_index: $run.to_index }
                do $controls.run_hdf5_reader $run.path $instance_settings
                sleep 1sec;
            }

        },
        "new_sub_dir": {|| ["true", ""] }
    }
}