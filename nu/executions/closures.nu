use ./benchmark.nu
use ./standard.nu
use ./stress_test.nu
use ./tests.nu

export def execution [settings: record, execution: string] : nothing -> closure {
    match $execution {
        standard    => {|deploy_pipeline, run_simulator, kill_pipeline| standard     $settings $deploy_pipeline $run_simulator $kill_pipeline },
        benchmark   => {|deploy_pipeline, run_simulator, kill_pipeline| benchmark    $settings $deploy_pipeline $run_simulator $kill_pipeline },
        tests       => {|deploy_pipeline, run_simulator, kill_pipeline| tests        $settings $deploy_pipeline $run_simulator $kill_pipeline },
        stress_test => {|deploy_pipeline, run_simulator, kill_pipeline| stress_test  $settings $deploy_pipeline $run_simulator $kill_pipeline },
    }
}