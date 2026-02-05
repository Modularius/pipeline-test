use ../settings.nu 'build_settings'

def main [broker: string, pipeline: string, detector: string] : nothing -> nothing {
    build_settings $broker $pipeline $detector | save -f "settings.json"
}