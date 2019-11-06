DROP INDEX CONCURRENTLY IF EXISTS "messages_id_uniq_idx";

CREATE UNIQUE INDEX CONCURRENTLY "messages_id_uniq_idx" ON "public"."messages"
  USING btree(id ASC NULLS LAST);
