# Use This Broker
g_BROKER="${g_LOCALHOST}:9092"

# Broker Topics
g_TRACE_TOPIC=Traces
g_DAT_EVENT_TOPIC=Events
g_FRAME_EVENT_TOPIC=FrameEvents
g_CONTROL_TOPIC=Controls
g_LOGS_TOPIC=Logs
g_SELOGS_TOPIC=SELogs
g_ALARMS_TOPIC=Alarms

# Trace Source Dependent Event Formation Settings
g_TTE_POLARITY=positive
g_TTE_BASELINE=0

# Digitisers Expected from Broker
g_DIGITISERS=-d$(seq -s"," 0 $g_MAX_DIGITISER)
g_FRAME_TTL_MS=3500

# Output Path
g_NEXUS_OUTPUT_PATH="Output/local"
g_NEXUS_ARCHIVE_PATH="archive/incoming/local"
g_RUN_TTL_MS=9000
