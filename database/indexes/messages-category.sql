DROP INDEX IF EXISTS message_store.messages_category;

CREATE INDEX messages_category ON message_store.messages (
  message_store.category(stream_name),
  global_position,
  message_store.category(metadata->>'correlationStreamName')
);
