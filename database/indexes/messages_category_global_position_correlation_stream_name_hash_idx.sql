DROP INDEX IF EXISTS messages_category_global_position_correlation_idx;

CREATE INDEX messages_category_global_position_correlation_stream_name_hash_idx ON messages (
  category(stream_name),
  global_position,
  category(metadata->>'correlationStreamName'),
  (@hash_64(stream_name))
);
