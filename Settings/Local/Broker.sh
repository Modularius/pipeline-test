set -a

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
g_EF_POLARITY=positive
g_EF_BASELINE=0

# Digitisers Expected from Broker
#g_DIGITISERS="-d4 -d5 -d6 -d7 -d8 -d9 -d10 -d11"
g_DIGITISERS="-d4,5,6,7,8,9,10,11"
g_FRAME_TTL_MS=200

# Where the Nexus Files go (according to the host)
g_NEXUS_ARCHIVE_HOST_PATH=./archive/incoming/hifi
g_NEXUS_LOCAL_HOST_PATH=./Output/Local

# Where the Nexus Files go (according to their containers)
#g_NEXUS_ARCHIVE_PATH="archive"
#g_NEXUS_LOCAL_PATH="local"
g_RUN_TTL_MS=2500
