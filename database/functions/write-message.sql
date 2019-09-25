CREATE OR REPLACE FUNCTION write_message(
  id varchar,
  stream_name varchar,
  "type" varchar,
  data jsonb,
  metadata jsonb DEFAULT NULL,
  expected_version bigint DEFAULT NULL
)
RETURNS bigint
AS $$
DECLARE
  message_id uuid;
  stream_version bigint;
  position bigint;
  category varchar;
  stream_name_hash bigint;
BEGIN
  message_id = uuid(write_message.id);

  category := category(write_message.stream_name);
  stream_name_hash := hash_64(category);
  PERFORM pg_advisory_xact_lock(stream_name_hash);

  stream_version := stream_version(write_message.stream_name);

  if stream_version is null then
    stream_version := -1;
  end if;

  if write_message.expected_version is not null then
    if write_message.expected_version != stream_version then
      raise exception
        'Wrong expected version: % (Stream: %, Stream Version: %)',
        write_message.expected_version,
        write_message.stream_name,
        stream_version;
    end if;
  end if;

  position := stream_version + 1;

  insert into "messages"
    (
      "id",
      "stream_name",
      "position",
      "type",
      "data",
      "metadata"
    )
  values
    (
      message_id,
      write_message.stream_name,
      position,
      write_message.type,
      write_message.data,
      write_message.metadata
    )
  ;

  return position;
END;
$$ LANGUAGE plpgsql
VOLATILE;
