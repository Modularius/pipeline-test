use ./benchmark.nu
use ./standard.nu
use ./stress_test.nu
use ./tests.nu
use ./simulator.nu
use ./reader.nu

export def execution [settings: record, execution: string] : nothing -> closure {
    match $execution {
        standard    => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            standard     $settings $controls
        },
        benchmark   => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            benchmark    $settings $controls
        },
        tests       => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            tests        $settings $controls
        },
        stress_test => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            stress_test  $settings $controls
        },
        simulator   => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            simulator    $settings $controls
        },
        reader      => {|controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>|
            reader       $settings $controls
        },
    }
}