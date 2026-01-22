use ./prelude.nu 'print heading'

let kill_closures = {
    host: {|settings: record|
        print heading "killing all host processes"
        let components = [ "trace_to_events", "digitiser_aggregator", "nexus_writer", "simulator" ]
        for comp in $components {
            
            let name = ($settings.components | get $comp).process_name
            "pkill --signal SIGINT " ++ $name | print
            pkill -e --signal SIGINT $name | print
        }
    },
    containers: {|settings: record|
        
    }
}

def main [mode: string] {
    let settings: record = open "settings.json"

    do ($kill_closures | get $mode) $settings
}