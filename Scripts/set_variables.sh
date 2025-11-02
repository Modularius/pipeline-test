set_pipeline_local_variables() {
    LOCAL_PIPELINE_NAME=$1;shift;
    DAT_EVENT_TOPIC_SUFFIX=$1;shift;
    FRAME_EVENT_TOPIC_SUFFIX=$1;shift;
    set -a -u

    #
    # Set Local Variables
    #
    #if [ -v LOCAL_PIPELINE_NAME ]; then
    #    PIPELINE_NAME=${g_PIPELINE_NAME}_${LOCAL_PIPELINE_NAME}
    #else
    #    PIPELINE_NAME=${g_PIPELINE_NAME}
    #fi
    
    # Broker Settings
    BROKER=${g_BROKER}
    if [ -v LOCAL_PIPELINE_NAME ]; then
        GROUP_EVENT_FORMATION=${g_GROUP_EVENT_FORMATION}-${LOCAL_PIPELINE_NAME}
        GROUP_AGGREGATOR=${g_GROUP_AGGREGATOR}-${LOCAL_PIPELINE_NAME}
        GROUP_WRITER=${g_GROUP_WRITER}-${LOCAL_PIPELINE_NAME}
    else
        GROUP_EVENT_FORMATION=${g_GROUP_EVENT_FORMATION}
        GROUP_AGGREGATOR=${g_GROUP_AGGREGATOR}
        GROUP_WRITER=${g_GROUP_WRITER}
    fi

    TRACE_TOPIC=${g_TRACE_TOPIC}
    if [ -v DAT_EVENT_TOPIC_SUFFIX ]; then
        DAT_EVENT_TOPIC=${g_DAT_EVENT_TOPIC}-${DAT_EVENT_TOPIC_SUFFIX}
    else
        DAT_EVENT_TOPIC=${g_DAT_EVENT_TOPIC}
    fi
    if [ -v FRAME_EVENT_TOPIC_SUFFIX ]; then
        FRAME_EVENT_TOPIC=${g_FRAME_EVENT_TOPIC}-${FRAME_EVENT_TOPIC_SUFFIX}
    else
        FRAME_EVENT_TOPIC=${g_FRAME_EVENT_TOPIC}
    fi
    CONTROL_TOPIC=${g_CONTROL_TOPIC}
    LOGS_TOPIC=${g_LOGS_TOPIC}
    SELOGS_TOPIC=${g_SELOGS_TOPIC}
    ALARMS_TOPIC=${g_ALARMS_TOPIC}

    # Observability
    RUST_LOG=${g_RUST_LOG}
    NO_COLOR=${g_NO_COLOR}
    OTEL_LEVEL=${g_OTEL_LEVEL}

    OBSV_ADDRESS_EVENT_FORMATION=${g_OBSV_ADDRESS_EVENT_FORMATION}
    OBSV_ADDRESS_AGGREGATOR=${g_OBSV_ADDRESS_AGGREGATOR}
    OBSV_ADDRESS_WRITER=${g_OBSV_ADDRESS_WRITER}
    
    OTEL_ENDPOINT=${g_OTEL_ENDPOINT}
    
    OTEL_LEVEL=${g_OTEL_LEVEL}

    # Trace Source Dependent Event Formation Settings
    EF_POLARITY=${g_EF_POLARITY}
    EF_BASELINE=${g_EF_BASELINE}
    EF_INPUT_MODE=${g_EF_INPUT_MODE}
    EF_THRESHOLD=${g_EF_THRESHOLD}
    EF_DURATION=${g_EF_DURATION}
    EF_COOLOFF=${g_EF_COOLOFF}
    EF_CONSTANT_MULTIPLE=${g_EF_CONSTANT_MULTIPLE}
    EF_INPUT_COMMAND="${EF_INPUT_MODE} ${EF_THRESHOLD} ${EF_DURATION} ${EF_COOLOFF} ${EF_CONSTANT_MULTIPLE}"

    # Digitisers Expected from Broker
    DIGITISERS=${g_DIGITISERS}
    FRAME_TTL_MS=${g_FRAME_TTL_MS}

    # Output Path
    if [ -v LOCAL_PIPELINE_NAME ]; then
        NEXUS_LOCAL_HOST_PATH=${g_NEXUS_LOCAL_HOST_PATH}_${LOCAL_PIPELINE_NAME}
        NEXUS_ARCHIVE_HOST_PATH=${g_NEXUS_ARCHIVE_HOST_PATH}_${LOCAL_PIPELINE_NAME}
    else
        NEXUS_LOCAL_HOST_PATH=${g_NEXUS_LOCAL_HOST_PATH}
        NEXUS_ARCHIVE_HOST_PATH=${g_NEXUS_ARCHIVE_HOST_PATH}
    fi
    RUN_TTL_MS=${g_RUN_TTL_MS}

    set_config_opts
}

set_config_opts() {
    set -a -u
    CONFIGURATION_OPTIONS='
{
"broker_settings":{
"broker":"$BROKER", 
"trace_to_events_group":"$GROUP_EVENT_FORMATION", 
"digitiser_aggregator_group":"$GROUP_AGGREGATOR", 
"nexus_writer_group":"$GROUP_WRITER"
}, 
"topics":{
"trace":"$TRACE_TOPIC", 
"dat_eventlists":"$DAT_EVENT_TOPIC", 
"frame_eventlist":"$FRAME_EVENT_TOPIC", 
"control":"$CONTROL_TOPIC", 
"logs":"$LOGS_TOPIC", 
"selogs":"$SELOGS_TOPIC", 
"alarms":"$ALARMS_TOPIC"
}, 
"event_formation":{
"polarity":"$EF_POLARITY", 
"baseline":$EF_BASELINE, 
"input_command":"$EF_INPUT_COMMAND"
}, 
"digitiser_aggregator":{
"digitisers":"$DIGITISERS", 
"frame_ttl_ms":$FRAME_TTL_MS
}, 
"nexus_writer":{
"local_host_path":"$NEXUS_LOCAL_HOST_PATH", 
"archive_host_path":"$NEXUS_ARCHIVE_HOST_PATH", 
"run_ttl_ms":$RUN_TTL_MS
}
}
'
    CONFIGURATION_OPTIONS=${CONFIGURATION_OPTIONS//$'\n'/}
}
