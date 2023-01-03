DROP INDEX IF EXISTS message_store.messages_category_correlation;

CREATE INDEX messages_category_correlation ON message_store.messages (
  message_store.category(stream_name),
  message_store.category(metadata->>'correlationStreamName'),
  global_position
);
