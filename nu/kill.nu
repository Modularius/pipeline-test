use ./modes/closures.nu mode
use ./build/settings.nu SETTINGS_PATH

def main [mode: string] {
    let settings: record = open $SETTINGS_PATH
    
    do (mode $mode $settings | get kill_pipeline) $settings

    #do ($kill_closures | get $mode) $settings
}