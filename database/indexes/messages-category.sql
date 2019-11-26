DROP INDEX IF EXISTS messages_category;

CREATE INDEX messages_category ON messages (
  category(stream_name),
  global_position,
  category(metadata->>'correlationStreamName')
);
