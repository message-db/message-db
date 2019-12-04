DROP INDEX IF EXISTS messages_stream;

CREATE UNIQUE INDEX messages_stream ON message_store.messages (
  stream_name,
  position
);
