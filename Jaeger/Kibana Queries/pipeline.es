PUT _ingest/pipeline/convert-tags-to-fields
{
  "description": "Extracts Key-Value pairs and add them as fields.",
  "processors": [
    {
      "script": {
        "lang": "painless",
        "source": """
            for(tag in ctx.tags)
            {
              ctx["tags." + tag.key] = tag.value;
            }
            for(tag in ctx.process.tags)
            {
              ctx.process["tags." + tag.key] = tag.value;
            }
            for(tag in ctx.references)
            {
              ctx["references." + tag.refType.toLowerCase() + ".spanID"] = tag.spanID;
              ctx["references." + tag.refType.toLowerCase() + ".traceID"] = tag.traceID;
            }
            ctx.remove("tags");
            ctx.process.remove("tags");
            ctx.remove("references");

            //  Remove Unneded Tags, if found
            ctx.remove("tags.code.filepath");
            ctx.remove("tags.code.lineno");
            ctx.remove("tags.code.namespace");
            ctx.remove("tags.span.kind");
            ctx.remove("tags.internal.span.format");
            ctx.remove("tags.otel.scope.name");
            ctx.remove("tags.otel.scope.version");
            ctx.remove("tags.thread.id");
            ctx.remove("tags.thread.name");
          """
      }
    }
  ]
}
DELETE _ingest/pipeline/convert-tags-to-fields



POST _reindex
{
  "source": {
    "index": "jaeger-span-2025-02-10"
  },
  "dest": {
    "index": "processed-jaeger-span-2025-02-10",
    "op_type": "create",
    "pipeline": "convert-tags-to-fields"
  }
}

DELETE /processed-jaeger-span-2025-02-09

docker run -e SPAN_STORAGE_TYPE=elasticsearch jaegertracing/jaeger-collector:latest --help