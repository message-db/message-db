DROP INDEX CONCURRENTLY IF EXISTS "messages_stream_name_position_uniq_idx";

CREATE UNIQUE INDEX CONCURRENTLY "messages_stream_name_position_uniq_idx" ON "public"."messages"
  USING btree(stream_name COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST,
    "position" "pg_catalog"."int8_ops" ASC NULLS LAST);
