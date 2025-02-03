# Get Mapping From Index
GET /jaeger-span-2025-02-02/_mapping

GET /jaeger-span-2025-02-02/_search
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "comments": {
      "nested": {
        "path": "references"
      },
      "aggs": {
        "top_usernames": {
          "terms": {
            "field": "references.spanID"
          },
          "aggs": {
            "comment_to_issue": {
              "reverse_nested": {}, 
              "aggs": {
                "top_tags_per_comment": {
                  "terms": {
                    "field": "spanID"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}