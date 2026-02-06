let settings: record = open "settings.json"

def main [component: string, --format(-f)=true, tail: int = 10] : nothing -> table {
    let name = [$settings.broker.pipeline_name, $component, "1"] | str join "_"
    if $format {
        podman logs --tail ($tail | default 10) $name
            | lines
            | parse "{Date}T{Time}Z  {Level} {temp}"
            #| move Message --after Level
            | each {|row| $row | insert Message {($row.temp | str replace ": " "\n")} | reject temp }
            | table --index false --expand --theme thin
    } else {
        podman logs --tail ($tail | default 10) $name | lines
    }
}