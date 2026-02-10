use ./build/settings.nu ['SETTINGS_PATH', 'build_settings']

def main [broker: string, pipeline: string, detector: string] : nothing -> nothing {
    build_settings $broker $pipeline $detector | save -f $SETTINGS_PATH
}