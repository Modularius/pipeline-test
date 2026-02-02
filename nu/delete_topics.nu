let settings: record = open "settings.json"

export def 'main' [] {
    let topics = $settings.broker.topics
    podman exec kafka rpk topic delete ...($topics | values)
    podman exec kafka rpk topic create ...($topics | values)
}