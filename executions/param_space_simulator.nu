use ../nu/build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]
use ../nu/build/analysis.nu analyse_test_file

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            "Running Param Explorer Execution" | print_title

            let dat_event = [$settings.broker.topics.dat_event, "true"] | str join "_"
            let subdir_trace = [$settings.broker.nexus_writer.subdirectory, "detector"] | str join "/"
            let subdir_dat_event = [$settings.broker.nexus_writer.subdirectory, "true"] | str join "/"

            let env_args = {};
            let instance_settings =  { dat_event: $dat_event }
            let path = "Simulations/ParamSpace/noisy.json"

            let no_noise = { "MAX_UNIFORM_NOISE": "0","SD_GAUSSIAN_NOISE": "0" }
            let low_noise = { "MAX_UNIFORM_NOISE": "50","SD_GAUSSIAN_NOISE": "300" }
            let high_noise = { "MAX_UNIFORM_NOISE": "200","SD_GAUSSIAN_NOISE": "1000" }

            let low_count = { "MIN_PULSES": "25", "MAX_PULSES": "26" }
            let high_count = { "MIN_PULSES": "200", "MAX_PULSES": "201" }

            let runs = [
                #{ name: "NoNoiseLowCount", noise: $no_noise, count: $low_count },
                #{ name: "LowNoiseLowCount", noise: $low_noise, count: $low_count },
                #{ name: "HighNoiseLowCount", noise: $high_noise, count: $low_count },
                { name: "NoNoiseHighCount", noise: $no_noise, count: $high_count },
                #{ name: "LowNoiseHighCount", noise: $low_noise, count: $high_count },
                { name: "HighNoiseHighCount", noise: $high_noise, count: $high_count },
            ]
            $runs | each {|run|
                let envs = $env_args | merge $run.noise | merge $run.count | merge { "RUN_NAME": $run.name };
                do $controls.run_simulator $path $envs $instance_settings;
                let filepath_trace = $run.name | wait_until_run_completed $settings { new_subdir:$subdir_trace };
                let filepath_eventlists = $run.name | wait_until_run_completed $settings { new_subdir:$subdir_dat_event };
                sleep 1sec;
                #python "analysis.py" $filepath_trace $filepath_eventlists
            }

        },
        "new_sub_dir": {|| ["true", "detector"] }
    }
}