use ./build/prelude.nu print_heading
use ./build/simulator_closures.nu run_simulator_closures
use ./build/pipeline_closures.nu deploy_pipeline_closures
use ./executions/benchmark.nu
use ./executions/tests.nu
use ./executions/stress_test.nu

let settings: record = open "settings.json"

let execution_closures = {
    benchmark:   {|deploy_pipeline, run_simulator, kill_pipeline| benchmark    $settings $deploy_pipeline $run_simulator $kill_pipeline },
    tests:       {|deploy_pipeline, run_simulator, kill_pipeline| tests        $settings $deploy_pipeline $run_simulator $kill_pipeline },
    stress_test: {|deploy_pipeline, run_simulator, kill_pipeline| stress_test  $settings $deploy_pipeline $run_simulator $kill_pipeline },
}

def main [mode: string, execution: string] {
    let deploy_pipeline = deploy_pipeline_closures $settings $mode
    let run_simulator = run_simulator_closures $settings $mode
    let kill_pipeline = { nu ./nu/kill.nu $mode }

    do ($execution_closures | get $execution) $deploy_pipeline $run_simulator $kill_pipeline
}