DROP INDEX CONCURRENTLY IF EXISTS "messages_metadata_correlation_idx";
CREATE UNIQUE INDEX CONCURRENTLY "messages_metadata_correlation_idx" ON "public"."messages" USING btree((metadata->>'correlationStreamName') ASC NULLS LAST);
