use ./prelude.nu 'print heading'

let settings: record = open "settings.json"

print heading "killing all host processes"

let components = [ "trace_to_events", "digitiser_aggregator", "nexus_writer", "simulator" ]
for comp in $components {
    let name = ($settings.constants.components | get $comp).process_name
    "pkill --signal SIGINT " ++ $name | print
    pkill -e --signal SIGINT $name | print
}