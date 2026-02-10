use ./../build/settings.nu SETTINGS_PATH
let settings: record = open $SETTINGS_PATH

def main [component: string, mode: string = "container", --format(-f)=true, tail: int = 10] : nothing -> table {
    match $mode {
        "host" => {
            let name = ["output", $component] | str join "."
            if $format {
                open $name
                    | lines
                    | parse "{Date}T{Time}Z {Level} {temp}"
                    #| move Message --after Level
                    | each {|row| $row | insert Message {($row.temp | str replace ": " "\n")} | reject temp }
                    | table --index false --expand --theme thin -a $tail
            } else {
                tail $name -n $tail | lines
            }
        },
        "container" => {
            let name = [$settings.broker.pipeline_name, $component, "1"] | str join "_"
            if $format {
                podman logs --tail ($tail | default 10) $name
                    | lines
                    | parse "{Date}T{Time}Z  {Level} {temp}"
                    #| move Message --after Level
                    | each {|row| $row | insert Message {($row.temp | str replace ": " "\n")} | reject temp }
                    | table --index false --expand --theme thin
            } else {
                podman logs --tail $tail $name | lines
            }
        }
    }
}