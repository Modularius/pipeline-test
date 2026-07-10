use ./benchmark.nu
use ./for_anthony.nu
use ./param_space_reader.nu
use ./param_space_simulator.nu
use ./reader.nu
use ./reader_writer.nu
use ./standard.nu
use ./stress_test.nu
use ./simulator.nu
use ./tests.nu
use ./writer.nu

export def execution [settings: record, execution: string] : nothing -> record<run: closure, new_sub_dir: closure> {
    match $execution {
        standard => {
            standard $settings
        },
        benchmark => {
            benchmark $settings
        },
        for_anthony => {
            for_anthony $settings
        },
        param_space_reader => {
            param_space_reader $settings
        },
        param_space_simulator => {
            param_space_simulator $settings
        },
        reader => {
            reader $settings
        },
        reader_writer => {
            reader_writer $settings
        },
        stress_test => {
            stress_test $settings
        },
        simulator => {
            simulator $settings
        },
        tests => {
            tests $settings
        },
        writer => {
            writer $settings
        },
    }
}