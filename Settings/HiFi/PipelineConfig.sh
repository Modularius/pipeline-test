# Use This Broker
g_BROKER="130.246.55.29:9092"

# Broker Topics
g_TRACE_TOPIC=daq-traces-in
g_DAT_EVENT_TOPIC=daq-events
g_FRAME_EVENT_TOPIC=frame-events
g_CONTROL_TOPIC=ics-control-change
g_LOGS_TOPIC=ics-metadata
g_SELOGS_TOPIC=ics-metadata
g_ALARMS_TOPIC=ics-alarms

# Trace Source Dependent Event Formation Settings
g_TTE_POLARITY=positive
g_TTE_BASELINE=0

# Digitisers Expected from Broker
g_DIGITIZERS="-d4 -d5 -d6 -d7 -d8 -d9 -d10 -d11"
g_FRAME_TTL_MS=1000

# Output Path
g_NEXUS_OUTPUT_PATH="Output/HiFi"
g_NEXUS_ARCHIVE_PATH="/mnt/archive/incoming/hifi/via-local"
g_RUN_TTL_MS=500