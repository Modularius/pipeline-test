use ../build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]
use ../build/analysis.nu analyse_test_file

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            "Running Param Explorer Trace Simulator Execution" | print_title

            let dat_event = [$settings.broker.topics.dat_event, "true"] | str join "_"

            let env_args = {};
            let instance_settings =  { dat_event: $dat_event }
            let path = "Simulations/ParamSpace/noisy_traces.json"

            let no_noise = { "MAX_UNIFORM_NOISE": "0","SD_GAUSSIAN_NOISE": "0" }
            let low_noise = { "MAX_UNIFORM_NOISE": "50","SD_GAUSSIAN_NOISE": "300" }
            let high_noise = { "MAX_UNIFORM_NOISE": "200","SD_GAUSSIAN_NOISE": "1000" }

            let low_count = { "MIN_PULSES": "25", "MAX_PULSES": "26" }
            let high_count = { "MIN_PULSES": "200", "MAX_PULSES": "201" }

            let test_index = $settings.test_index

            let runs = [
                #{ name: "NoNoiseLowCount", noise: $no_noise, count: $low_count, period: ($test_index * 6 + 0) },
                #{ name: "LowNoiseLowCount", noise: $low_noise, count: $low_count, period: ($test_index * 6 + 1) },
                { name: "HighNoiseLowCount", noise: $high_noise, count: $low_count, period: ($test_index * 6 + 2) },
                #{ name: "NoNoiseHighCount", noise: $no_noise, count: $high_count, period: ($test_index * 6 + 3) },
                #{ name: "LowNoiseHighCount", noise: $low_noise, count: $high_count, period: ($test_index * 6 + 4) },
                #{ name: "HighNoiseHighCount", noise: $high_noise, count: $high_count, period: ($test_index * 6 + 5) },
            ]
            $runs | each {|run|
                let envs = $env_args | merge $run.noise | merge $run.count | merge { "RUN_NAME": $run.name, "PERIOD": $run.period };
                do $controls.run_simulator $path $envs $instance_settings;
                sleep 2sec;
            }

        },
        "new_sub_dir": {|| ["true", ""] }
    }
}