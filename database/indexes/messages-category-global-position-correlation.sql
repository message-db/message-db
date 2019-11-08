DROP INDEX CONCURRENTLY IF EXISTS "messages_category_global_position_correlation_idx";

CREATE INDEX "messages_category_global_position_correlation_idx" ON "public"."messages"
  USING btree(category(stream_name) COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST,
    "global_position" "pg_catalog"."int8_ops" ASC NULLS LAST,
    category(metadata->>'correlationStreamName') ASC);
