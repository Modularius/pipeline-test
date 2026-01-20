use ./settings.nu 'build settings'

def main [broker: string, pipeline: string, detector: string] : nothing -> nothing {
    build settings $broker $pipeline $detector | save -f "settings.json"
}