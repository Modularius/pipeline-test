let settings: record = open "settings.json"

def main [component: string, --columns(-c), ...filter: oneof<int, string>] : nothing -> string {
    let name = [$settings.broker.pipeline_name, $component, "1"] | str join "_"
    let output = podman inspect $name | from json

    let output = $filter | reduce --fold $output {|name, acc| $acc | select $name | flatten }

    if $columns {
        $output | columns | print
    } else {
        $output | print
    }
}