use ./pipeline_control pc
use ./modes/host host

var local_broker = [
    &settings=[
        &pipeline=$pc:pipeline
        &execution_paths=$pc:execution_paths
        &process_names=$pc:process_names
        &broker_settings=(pc:generate_broker_settings "localhost" 8)
    ]
]

var benchmark_execution = [
    &run={|EXECUTION_PIPELINE_SRC|

    echo_subtitle "Executing Host Pipeline"
    execution_run_set_pipeline_name
    execution_pipeline_init

    sleep 3

    echo_subtitle "Executing Run"

    execution_pipeline_init_run 8 ShortTest "Benchmarks/timing.json"
    
    echo_subtitle "Run Execution Completed"
    }
]

fn pipeline_run {|broker_type run_mode execution|
    echo "var broker_type = $broker_type"
}

