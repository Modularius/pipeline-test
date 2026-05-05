use ../nu/build/prelude.nu [print_title, SUBHEADING_COLOUR, wait_until_run_completed]
use ../nu/build/analysis.nu analyse_test_file

export def main [settings: record] : nothing -> record<run: closure, new_sub_dir: closure> {
    {
        "run": {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            "Running Param Explorer Execution" | print_title

            #let dat_event = [$settings.broker.topics.dat_event, "direct"] | str join "_"

            let env_args = {};
            let instance_settings =  {} # dat_event: $dat_event }
            let path = "Simulations/ParamSpace/noisy.json"

            let no_noise = { "MAX_UNIFORM_NOISE": "0","SD_GAUSSIAN_NOISE": "0" }
            let low_noise = { "MAX_UNIFORM_NOISE": "50","SD_GAUSSIAN_NOISE": "300" }
            let high_noise = { "MAX_UNIFORM_NOISE": "200","SD_GAUSSIAN_NOISE": "1000" }

            let low_count = { "MIN_PULSES": "25", "MAX_PULSES": "26" }
            let high_count = { "MIN_PULSES": "200", "MAX_PULSES": "201" }

            let filename = "NoNoiseLowCount";
            do $controls.run_simulator $path ($env_args | merge $no_noise | merge $low_count | merge { "RUN_NAME": $filename }) $instance_settings;
            let filepath = $filename | wait_until_run_completed $settings; sleep 1sec;
            python "analysis.py" $filepath
            
            let filename = "LowNoiseLowCount";
            do $controls.run_simulator $path ($env_args | merge $low_noise | merge $low_count | merge { "RUN_NAME": $filename }) $instance_settings;
            let filepath = $filename | wait_until_run_completed $settings; sleep 1sec;
            python "analysis.py" $filepath
            
            let filename = "HighNoiseLowCount";
            do $controls.run_simulator $path ($env_args | merge $high_noise | merge $low_count | merge { "RUN_NAME": $filename }) $instance_settings;
            let filepath = $filename | wait_until_run_completed $settings; sleep 1sec;
            python "analysis.py" $filepath

            let filename = "NoNoiseHighCount";
            do $controls.run_simulator $path ($env_args | merge $no_noise | merge $high_count | merge { "RUN_NAME": $filename }) $instance_settings;
            let filepath = $filename | wait_until_run_completed $settings; sleep 1sec;
            python "analysis.py" $filepath

            let filename = "LowNoiseHighCount";
            do $controls.run_simulator $path ($env_args | merge $low_noise | merge $high_count | merge { "RUN_NAME": $filename }) $instance_settings;
            let filepath = $filename | wait_until_run_completed $settings; sleep 1sec;
            python "analysis.py" $filepath
            
            let filename = "HighNoiseHighCount";
            do $controls.run_simulator $path ($env_args | merge $high_noise | merge $high_count | merge { "RUN_NAME": $filename }) $instance_settings;
            let filepath = $filename | wait_until_run_completed $settings; sleep 1sec;
            python "analysis.py" $filepath

        },
        "new_sub_dir": {|| null }
    }
}