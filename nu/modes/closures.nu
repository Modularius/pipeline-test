use ./host.nu select_host
use ./container.nu select_container

export def mode [mode: string, settings: record] : nothing -> record {
    match $mode {
        "host" => (select_host $settings)
        "container" => (select_container $settings)
    }
}