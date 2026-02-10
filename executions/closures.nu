use ./benchmark.nu
use ./standard.nu
use ./stress_test.nu
use ./tests.nu
#use ./simulator.nu
#use ./reader.nu

export def execution [settings: record, execution: string] : nothing -> record<run: closure, new_sub_dir: closure> {
    match $execution {
        standard    => { standard $settings },
        benchmark   => { benchmark $settings },
        tests       => { tests $settings },
        stress_test => { stress_test $settings },
        simulator   => { simulator $settings },
        reader      => { reader $settings },
    }
}