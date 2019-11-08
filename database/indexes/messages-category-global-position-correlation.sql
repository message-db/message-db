DROP INDEX IF EXISTS messages_category_global_position_correlation_idx;

CREATE INDEX messages_category_global_position_correlation_idx ON messages (
  category(stream_name),
  global_position,
  category(metadata->>'correlationStreamName')
);
