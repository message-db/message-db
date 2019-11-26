DROP INDEX IF EXISTS messages_id;

CREATE UNIQUE INDEX messages_id ON messages (
  id
);
