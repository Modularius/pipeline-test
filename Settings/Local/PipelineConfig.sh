# Use This Broker
BROKER="localhost:9092"

# Broker Topics
TRACE_TOPIC=Traces
DAT_EVENT_TOPIC=Events
FRAME_EVENT_TOPIC=FrameEvents
CONTROL_TOPIC=Controls
LOGS_TOPIC=Logs
SELOGS_TOPIC=SELogs
ALARMS_TOPIC=Alarms

# Digitisers Expected from Broker
DIGITIZERS=$(build_digitiser_argument $MAX_DIGITISER)

# Output Path
NEXUS_OUTPUT_PATH="Output/Local"
