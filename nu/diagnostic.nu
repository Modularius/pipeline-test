use ./build/args.nu 'build_args diagnostics'

let settings: record = open "settings.json"

# Diagnose Daq Traces
^$settings.components.diagnostics.execution_path ...(build_args diagnostics $settings) | print
