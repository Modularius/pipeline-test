{
    match($0, /(.+)T(.+)\+00:00 stdout F (.+)T(.+)Z  WARN process_kafka_message{kafka_message_timestamp_ms=([0-9]+)}:process_digitiser_event_list_message{digitiser_id=([0-9]+) num_cached_frames=([0-9]+)}: digitiser_aggregator::frame::cache: Frame's timestamp earlier than or equal to the latest frame dispatched: (.+) UTC <= (.+) UTC/, out)
    print out[1] " " out[2] ", " out[3] " " out[4] ", " out[5] ", " out[6] ", " out[7] ", " out[8] ", " out[9]
}