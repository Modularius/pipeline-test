# Use This Broker
g_BROKER="130.246.55.29:9092"

# Broker Topics
g_TRACE_TOPIC=daq-traces-in
g_DAT_EVENT_TOPIC=daq-events
g_FRAME_EVENT_TOPIC=frame-events-test
g_CONTROL_TOPIC=ics-control-change
g_LOGS_TOPIC=ics-metadata
g_SELOGS_TOPIC=HIFI_sampleEnv
g_ALARMS_TOPIC=ics-alarms

# Trace Source Dependent Event Formation Settings
g_TTE_POLARITY=positive
g_TTE_BASELINE=0

# Digitisers Expected from Broker
g_NUM_DIGITISERS=8
g_MAX_DIGITISER=7
g_DIGITISERS="-d4,5,6,7,8,9,10,11"
g_FRAME_TTL_MS=5000

# Output Path
g_NEXUS_OUTPUT_PATH="Output/HiFi"
g_NEXUS_ARCHIVE_PATH="archive/incoming/hifi-via-local"
g_RUN_TTL_MS=500