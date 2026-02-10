use ./build/prelude.nu print_heading
use ./build/settings.nu SETTINGS_PATH
use ../executions/closures.nu execution
use ./modes/closures.nu mode

let settings: record = open $SETTINGS_PATH

def main [mode: string, execution: string] {
    #let deploy_pipeline = deploy_pipeline_closures $settings $mode
    #let run_simulator = run_simulator_closures $settings $mode
    #let kill_pipeline = { nu ./nu/kill.nu $mode }

    let mode = mode $mode $settings

    do (execution $settings $execution).run $mode
}