use ./build/prelude.nu print_heading
use ./build/settings.nu SETTINGS_PATH
use ../executions/closures.nu execution
use ./modes/closures.nu mode

let settings: record = open $SETTINGS_PATH

def main [mode: string, execution: string] {
    #let deploy_pipeline = deploy_pipeline_closures $settings $mode
    #let run_simulator = run_simulator_closures $settings $mode
    #let kill_pipeline = { nu ./nu/kill.nu $mode }

    let executions = execution $settings $execution

    let execution = $executions | get "run"
    

    let mode = mode $mode $settings
    $mode | describe | print

    do $execution $mode
}