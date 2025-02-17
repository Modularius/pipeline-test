PUT _index_template/jaeger-span
{
  "priority": 0,
  "template": {
    "settings": {
      "index": {
        "mapping": {
          "nested_fields": {
            "limit": "50"
          }
        },
        "requests": {
          "cache": {
            "enable": "true"
          }
        },
        "number_of_shards": "5",
        "number_of_replicas": "0",
        "final_pipeline": "convert-tags-to-fields"
      }
    },
    "mappings": {
      "numeric_detection": true,
      "dynamic": true,
      "dynamic_templates": [
        {
          "span_tags_map": {
            "path_match": "tag.*",
            "mapping": {
              "ignore_above": 256,
              "type": "keyword"
            }
          }
        },
        {
          "process_tags_map": {
            "path_match": "process.tag.*",
            "mapping": {
              "ignore_above": 256,
              "type": "keyword"
            }
          }
        }
      ],
      "properties": {
        "traceID": {
          "ignore_above": 256,
          "type": "keyword"
        },
        "process": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "object"
            },
            "serviceName": {
              "ignore_above": 256,
              "type": "keyword"
            },
            "tags": {
              "dynamic": false,
              "type": "nested",
              "properties": {
                "type": {
                  "ignore_above": 256,
                  "type": "keyword"
                },
                "value": {
                  "ignore_above": 256,
                  "type": "keyword"
                },
                "key": {
                  "ignore_above": 256,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "references": {
          "dynamic": false,
          "type": "nested",
          "properties": {
            "spanID": {
              "ignore_above": 256,
              "type": "keyword"
            },
            "traceID": {
              "ignore_above": 256,
              "type": "keyword"
            },
            "refType": {
              "ignore_above": 256,
              "type": "keyword"
            }
          }
        },
        "startTimeMillis": {
          "format": "epoch_millis",
          "type": "date"
        },
        "flags": {
          "type": "integer"
        },
        "operationName": {
          "ignore_above": 256,
          "type": "keyword"
        },
        "parentSpanID": {
          "ignore_above": 256,
          "type": "keyword"
        },
        "tags": {
          "dynamic": false,
          "type": "nested",
          "properties": {
            "type": {
              "ignore_above": 256,
              "type": "keyword"
            },
            "value": {
              "ignore_above": 256,
              "type": "keyword"
            },
            "key": {
              "ignore_above": 256,
              "type": "keyword"
            }
          }
        },
        "duration": {
          "type": "long"
        },
        "spanID": {
          "ignore_above": 256,
          "type": "keyword"
        },
        "startTime": {
          "type": "long"
        },
        "tag": {
          "type": "object"
        },
        "logs": {
          "dynamic": false,
          "type": "nested",
          "properties": {
            "fields": {
              "dynamic": false,
              "type": "nested",
              "properties": {
                "type": {
                  "ignore_above": 256,
                  "type": "keyword"
                },
                "value": {
                  "ignore_above": 256,
                  "type": "keyword"
                },
                "key": {
                  "ignore_above": 256,
                  "type": "keyword"
                }
              }
            },
            "timestamp": {
              "type": "long"
            }
          }
        }
      }
    }
  },
  "index_patterns": [
    "jaeger-span-*"
  ],
  "composed_of": [],
  "ignore_missing_component_templates": []
}