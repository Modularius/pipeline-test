use ../nu/build/prelude.nu [print_heading, print_title, HEADING_COLOUR, SUBHEADING_COLOUR, SUBSUBHEADING_COLOUR, wait_until_runs_completed]
use ../nu/build/analysis.nu analyse_test_file
use std/assert

export def main [settings: record, controls: record<deploy_pipeline: closure, run_simulator: closure, run_reader: closure, kill_pipeline: closure>] {
    {
        "run": {||
            "Running Standard Execution" | print_title

            do $controls.deploy_pipeline { suppress_archive: true }
        },
        "new_sub_dir": null
    }
}