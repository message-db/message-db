DROP INDEX CONCURRENTLY IF EXISTS messages_id_uniq_idx;

CREATE UNIQUE INDEX messages_id_uniq_idx ON messages (
  id
);
