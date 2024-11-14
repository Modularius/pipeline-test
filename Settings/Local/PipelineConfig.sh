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
TTE_POLARITY=positive
TTE_BASELINE=0

# Digitisers Expected from Broker
DIGITIZERS="-d4 -d5 -d6 -d7 -d8 -d9 -d10 -d11"

# Output Path
NEXUS_OUTPUT_PATH="local"
NEXUS_ARCHIVE_PATH="archive"
#NEXUS_OUTPUT_PATH="Output/Local"
#NEXUS_ARCHIVE_PATH="/mnt/archive/incoming/hifi"
