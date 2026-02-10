use ./build/args.nu 'build_args diagnostics'

use ./build/settings.nu SETTINGS_PATH
let settings: record = open $SETTINGS_PATH

# Diagnose Daq Traces
^$settings.components.diagnostics.execution_path ...(build_args diagnostics $settings) | print
