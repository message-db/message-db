DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'message') THEN
    CREATE TYPE message AS (
      id varchar,
      stream_name varchar,
      type varchar,
      position bigint,
      global_position bigint,
      data varchar,
      metadata varchar,
      time timestamp
    );
  END IF;
END$$;
