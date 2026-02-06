use ./host.nu select_host
use ./container.nu select_container

export def mode [mode: string, settings: record] : nothing -> record<deploy_pipeline:closure, kill_pipeline:closure, run_simulator:closure, run_reader:closure> {
    match $mode {
        "host" => (select_host $settings)
        "container" => (select_container $settings)
    }
}