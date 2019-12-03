DO $$
BEGIN
  DROP TYPE IF EXISTS message_store.message CASCADE;

  CREATE TYPE message_store.message AS (
    id varchar,
    stream_name varchar,
    type varchar,
    position bigint,
    global_position bigint,
    data varchar,
    metadata varchar,
    time timestamp
  );
END$$;
