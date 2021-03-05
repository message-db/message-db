CREATE TABLE IF NOT EXISTS message_store.messages (
  global_position bigserial NOT NULL,
  position bigint NOT NULL,
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  time TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'utc') NOT NULL,
  stream_name text NOT NULL,
  type text NOT NULL,
  data jsonb,
  metadata jsonb
);

ALTER TABLE message_store.messages ADD PRIMARY KEY (global_position) NOT DEFERRABLE INITIALLY IMMEDIATE;
