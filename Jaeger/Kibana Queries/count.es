GET jaeger-span-2025-02-10-14/_search
{
  "_source": false,
  "size": 0,
  "aggregations": {
    "count_traces": {
      "filter": { "term": { "operationName": "process_digitiser_trace_message" } }
    },
    "count_digitiser_eventlists": {
      "filter": { "term": { "operationName": "process_digitiser_event_list_message" } }
    },
    "count_frame_eventlists": {
      "filter": { "term": { "operationName": "process_frame_assembled_event_list_message" } }
    },
    "count_Frames": {
      "filter": { "term": { "operationName": "Frame" } }
    }
  }
}

GET processed-jaeger-span-2025-02-10-14/_search
{
  "_source": false,
  "size": 0,
  "aggregations": {
    "count_traces": {
      "filter": { "term": { "operationName": "process_digitiser_trace_message" } }
    },
    "count_digitiser_eventlists": {
      "filter": { "term": { "operationName": "process_digitiser_event_list_message" } }
    },
    "count_frame_eventlists": {
      "filter": { "term": { "operationName": "process_frame_assembled_event_list_message" } }
    },
    "count_Frames": {
      "filter": { "term": { "operationName": "Frame" } }
    },
    "count_discarded_digitiser_eventlists": {
      "filter": {
        "bool": {
          "must": [
            { "term": { "operationName": "process_digitiser_event_list_message" } },
            { "term": { "tags.is_discarded": "false" } }
          ]
        }
      }
    }
  }
}
