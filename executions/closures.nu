use ./benchmark.nu
use ./standard.nu
use ./stress_test.nu
use ./tests.nu
use ./simulator.nu
use ./reader.nu

export def execution [settings: record, execution: string] : nothing -> record<run: closure, new_sub_dir: closure> {
    match $execution {
        standard    => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            standard $settings
        },
        benchmark   => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            benchmark $settings
        },
        tests       => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            tests $settings
        },
        stress_test => {
            stress_test $settings
        },
        simulator   => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            simulator $settings
        },
        reader      => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            reader $settings
        },
    }
}