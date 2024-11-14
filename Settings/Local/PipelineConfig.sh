# Use This Broker
g_BROKER="localhost:9092"

# Broker Topics
g_TRACE_TOPIC=daq-traces-in
g_DAT_EVENT_TOPIC=daq-events-in
g_FRAME_EVENT_TOPIC=ics-_events
g_CONTROL_TOPIC=ics-control-change
g_LOGS_TOPIC=ics-metadata
g_SELOGS_TOPIC=ics-metadata
g_ALARMS_TOPIC=ics-alarms

# Digitisers Expected from Broker
g_DIGITIZERS=$(build_digitiser_argument 7)

# Output Path
g_NEXUS_OUTPUT_PATH="Output/Local"
