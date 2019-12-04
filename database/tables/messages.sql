CREATE TABLE IF NOT EXISTS message_store.messages (
  id UUID NOT NULL DEFAULT message_store.gen_random_uuid(),
  stream_name text NOT NULL,
  type text NOT NULL,
  position bigint NOT NULL,
  global_position bigserial NOT NULL,
  data jsonb,
  metadata jsonb,
  time TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'utc') NOT NULL
);

ALTER TABLE message_store.messages ADD PRIMARY KEY (global_position) NOT DEFERRABLE INITIALLY IMMEDIATE;
