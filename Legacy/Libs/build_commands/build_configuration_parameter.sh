build_configuration_parameter() {
    EF_INPUT_MODE=$1;shift;
    EF_MEM=$1;shift;
    
    DIGITISERS=$1;shift;
    FRAME_TTL_MS=$1;shift;
    FRAME_BUFFER_SIZE=$1;shift;
    DA_MEM=$1;shift;

    RUN_TTL_MS=$1;shift;
    NW_MEM=$1;shift;

    EF_CONFIGURATION_OPTIONS="cli-options: ${EF_INPUT_MODE}, memory: ${EF_MEM}"
    DA_CONFIGURATION_OPTIONS="digitisers: \"${DIGITISERS}\", frame_ttl_ms: ${FRAME_TTL_MS}, frame_buffer_size: ${FRAME_BUFFER_SIZE}, memory: ${DA_MEM}"
    NW_CONFIGURATION_OPTIONS="run_ttl_ms: ${RUN_TTL_MS}, memory: ${NW_MEM}"
    "event-formation-config:{${EF_CONFIGURATION_OPTIONS}}, digitiser-aggregator-config: {${DA_CONFIGURATION_OPTIONS}}, nexus-writer-config: {${NW_CONFIGURATION_OPTIONS}}" 
}