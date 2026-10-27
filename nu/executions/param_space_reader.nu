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
                    from_index: 0, to_index: 26511,
                    from_frame: 119838597, to_frame: 119865108
                },
            #]
            #let no_runs = [
                {
                    path: "archive/traces/trace-proto.h5",
                    from_index: 26512, to_index: 26640,
                    from_frame: 119877707, to_frame: 119890273
                },
                {
                    path: "archive/traces/trace-proto2.h5",
                    from_index: 0, to_index: 6584,
                    from_frame: 119902850, to_frame: 119909434
                },
                #{
                #    path: "archive/traces/trace-proto3.h5",
                #    from_index: 0, to_index: 6585,
                #    from_frame: 119921532, to_frame: 119928117
                #},
                #{
                #    path: "archive/traces/trace-proto3.h5",
                #    use_indices: true,
                #    from_index: 6586, to_index: 6714
                #},
                {
                    path: "archive/traces/trace-proto4.h5",
                    from_index: 0, to_index: 6576,
                    from_frame: 119958943, to_frame: 119965519
                },
                #{
                #    path: "archive/traces/trace-proto4.h5",
                #    use_indices: true,
                #    from_index: 6577, to_index: 6605
                #},
                {
                    path: "archive/traces/trace-proto5.h5",
                    from_index: 0, to_index: 2664,
                    from_frame: 119995253, to_frame: 119997917
                }
            ]
            let read_seq = $runs | each {|run| $'{"fc": [($run.from_frame | into string), (128 | into string)]}' } | str join ','
            #let read_seq = $runs | each {|run| $'{"fc": [($run.from_frame | into string), (480 | into string)]}' } | str join ','
            #let read_seq = '{"all" : null}'
            let instance_settings = $instance_settings | merge {
                sample_rate: 1_000_000_000,
                #overwrite_period: $settings.test_index
            }
            
            #do $controls.run_hdf5_reader "archive/traces/trace.h5" $read_seq $instance_settings
            do $controls.run_hdf5_reader "traces/musr2.h5" $read_seq $instance_settings
            #sleep 4sec;
            #[] | each {|run|
                #let instance_settings = $instance_settings | merge {
                #    sample_rate: 1_000_000_000,
                #    use_indices: ($run.use_indinuces? | default false),
                #    from_index: ($run.from_index? | default 0), to_index: ($run.to_index? | default 0),
                #    use_frames: ($run.use_frames? | default false),
                #    from_frame: ($run.from_frame? | default 0), to_frame: ($run.to_frame? | default 0),
                #}
                #do $controls.run_hdf5_reader $run.path $instance_settings
                #sleep 4sec;
            #}

        },
        "new_sub_dir": {|| ["true", ""] }
    }
}