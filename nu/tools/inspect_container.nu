let settings: record = open "settings.json"

def main [component: string, filter?: string] : nothing -> string {
    let name = [$settings.broker.pipeline_name, $component, "1"] | str join "_"
    let output = podman inspect $name | from json

    if ($filter | default "") == "" {
        $output | columns | print
    } else {
        $output | select $filter | flatten | print
    }
}