use ../build/prelude.nu [print_heading, print_title, HEADING_COLOUR, SUBHEADING_COLOUR, SUBSUBHEADING_COLOUR, wait_until_runs_completed]
use ../build/analysis.nu analyse_test_file
use std/assert

### This indicates that we do not change the ddefault nexus file subdirectory.
export def new_subdir [] : nothing -> oneof<string,nothing> { null }

export def main [settings: record, deploy_pipeline: closure, run_simulator: closure, kill_pipeline: closure] {
    "Running Standard Execution" | print_title

    do $deploy_pipeline
}