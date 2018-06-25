CREATE UNIQUE INDEX CONCURRENTLY "messages_id_uniq_idx" ON "public"."messages" USING btree(id ASC NULLS LAST);
