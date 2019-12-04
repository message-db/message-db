DROP INDEX IF EXISTS message_store.messages_id;

CREATE UNIQUE INDEX messages_id ON message_store.messages (
  id
);
