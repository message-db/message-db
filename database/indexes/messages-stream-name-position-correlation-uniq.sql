DROP INDEX CONCURRENTLY IF EXISTS messages_stream_name_position_correlation_uniq_idx;

CREATE UNIQUE INDEX messages_stream_name_position_correlation_uniq_idx ON messages (
  stream_name,
  position,
  category(metadata->>'correlationStreamName')
);
