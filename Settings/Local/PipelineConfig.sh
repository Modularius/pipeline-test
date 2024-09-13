# Use This Broker
BROKER="localhost:9092"

# Broker Topics
TRACE_TOPIC=daq-traces-in
DAT_EVENT_TOPIC=daq-events-in
FRAME_EVENT_TOPIC=ics-_events
CONTROL_TOPIC=ics-control-change
LOGS_TOPIC=ics-metadata
SELOGS_TOPIC=ics-metadata
ALARMS_TOPIC=ics-alarms

# Digitisers Expected from Broker
DIGITIZERS=$(build_digitiser_argument 7)

# Output Path
NEXUS_OUTPUT_PATH="Output/Local"
