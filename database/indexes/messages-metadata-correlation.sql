DROP INDEX CONCURRENTLY IF EXISTS "messages_metadata_correlation_idx";

CREATE INDEX CONCURRENTLY "messages_metadata_correlation_idx" ON "public"."messages"
  USING btree(category(metadata->>'correlationStreamName') ASC)
  WHERE (category(metadata->>'correlationStreamName') is not null);
