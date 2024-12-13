# Use This Broker
BROKER="130.246.55.29:9092"

# Broker Topics
TRACE_TOPIC=daq-traces-in
DAT_EVENT_TOPIC=daq-events
FRAME_EVENT_TOPIC=frame_events
CONTROL_TOPIC=ics-control-change
LOGS_TOPIC=ics-metadata
SELOGS_TOPIC=ics-metadata
ALARMS_TOPIC=ics-alarms

# Trace Source Dependent Event Formation Settings
EF_POLARITY=positive
EF_BASELINE=0

# Digitisers Expected from Broker
DIGITIZERS="-d4 -d5 -d6 -d7 -d8 -d9 -d10 -d11"

# Where the Nexus Files go (according to the host)
NEXUS_ARCHIVE_MOUNT=./archive/incoming/hifi
NEXUS_LOCAL_MOUNT=./Output/Local

# Where the Nexus Files go (according to their containers)
#NEXUS_ARCHIVE_PATH="archive"
#NEXUS_LOCAL_PATH="local"
NEXUS_ARCHIVE_PATH=./archive/incoming/hifi
NEXUS_LOCAL_PATH=./Output/Test
