# Use This Broker
g_BROKER="localhost:9092"

# Broker Topics
g_TRACE_TOPIC=Traces
g_DAT_EVENT_TOPIC=Events
g_FRAME_EVENT_TOPIC=FrameEvents
g_CONTROL_TOPIC=Controls
g_LOGS_TOPIC=Controls
g_SELOGS_TOPIC=Controls
g_ALARMS_TOPIC=Controls

# Trace Source Dependent Event Formation Settings
g_TTE_POLARITY=positive
g_TTE_BASELINE=0

# Digitisers Expected from Broker
g_DIGITIZERS=$(build_digitiser_argument $g_MAX_DIGITISER)
g_FRAME_TTL_MS=1000

# Output Path
g_NEXUS_OUTPUT_PATH="Output/Local"
g_NEXUS_ARCHIVE_PATH="/mnt/archive/incoming/local"
g_RUN_TTL_MS=500
