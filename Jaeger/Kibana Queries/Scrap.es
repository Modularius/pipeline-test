# Get Mapping From Index
GET /jaeger-span-2025-02-02/_mapping



######### Find Span with given 

### Tags
#frame_is_expired
#metadata_timestamp
#digitiser_id

### operationName
#Frame
#process_kafka_message
#process_digitiser_trace_message
#process_digitiser_event_list_message

POST /jaeger-span-2025-02-11-*/_search
{
  "_source": false,
  "query": {
    "bool": {
      "must": [
        {
          "nested": {
            "path": "tags",
            "query": {
              "bool": {
                "must": [
                  {"term": {"tags.key": "frame_is_expired"}},
                  {"term": {"tags.value": "2025-02-11T09:37:39.779523060+00:00"}}
                ]
              }
            }
          }
        },
        { "term": {"operationName": "Frame"} }
      ]
    }
  }
}



GET jaeger-span-*/_search
{
  "_source": [
      "startTimeMillis", "duration"
    ],
    "query": {
        "term": {
            "spanID": "753327ced9a45bff"
        }
    }
}


POST /jaeger-span-2025-02-10-*/_search
{
  "_source": false,
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {
          "nested": {
            "path": "tags",
            "query": {
              "bool": {
                "must": [
                  { "term": { "tags.key": "is_discarded" } },
                  { "term": { "tags.value": "false" } }
                ]
              }
            }
          }
        },
        {
          "term": { "operationName": "process_digitiser_event_list_message" }
        }
      ]
    }
  },
  "aggs": {
    "tags": {
      "nested": {
        "path": "tags"
      },
      "aggs": {
        "key_is_num_cached_frames": {
          "filter": { "term": { "tags.key": "num_cached_frames" } },
          "aggs": {
            "num_cached_frames": { "terms": { "field": "tags.value" } },
            "num_cached_frames_numeric": {
              "bucket_script": {
                "buckets_path": { "value": "num_cached_frames" },
                "script": "Integer.parseInt(params.value.value.keyword)"
              }
            }
          }
        }
      }
    }
  }
}