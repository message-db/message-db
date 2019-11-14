DO $$
BEGIN
  DROP TYPE IF EXISTS  CASCADE;

  CREATE TYPE category_message AS (
    id varchar,
    stream_name varchar,
    type varchar,
    position bigint,
    global_position bigint,
    data varchar,
    metadata varchar,
    time timestamp,
    stream_name_hash bigint,
    stream_name_modulo bigint
  );
END$$;
