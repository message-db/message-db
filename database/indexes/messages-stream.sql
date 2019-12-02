DROP INDEX IF EXISTS messages_stream;

CREATE UNIQUE INDEX messages_stream ON messages (
  stream_name,
  position
);
