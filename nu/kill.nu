use ./modes/closures.nu mode

def main [mode: string] {
    let settings: record = open "settings.json"

    do (mode $mode $settings | get kill_pipeline) $settings

    #do ($kill_closures | get $mode) $settings
}