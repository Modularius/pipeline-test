let settings: record = open "settings.json"

def main [component: string, tail: int = 10] : nothing -> string {
    let name = [$settings.broker.pipeline_name, $component, "1"] | str join "_"
    podman logs --tail ($tail | default 10) $name
}