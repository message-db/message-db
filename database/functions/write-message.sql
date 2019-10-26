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
  _message_id uuid;
  _stream_version bigint;
  _position bigint;
  _category varchar;
  _stream_name_hash bigint;
BEGIN
  _message_id = uuid(write_message.id);

  _category := category(write_message.stream_name);
  _stream_name_hash := hash_64(_category);
  PERFORM pg_advisory_xact_lock(_stream_name_hash);

  _stream_version := stream_version(write_message.stream_name);

  if _stream_version is null then
    _stream_version := -1;
  end if;

  if write_message.expected_version is not null then
    if write_message.expected_version != _stream_version then
      raise exception
        'Wrong expected version: % (Stream: %, Stream Version: %)',
        write_message.expected_version,
        write_message.stream_name,
        _stream_version;
    end if;
  end if;

  _position := _stream_version + 1;

  insert into messages
    (
      id,
      stream_name,
      position,
      type,
      data,
      metadata
    )
  values
    (
      _message_id,
      write_message.stream_name,
      _position,
      write_message.type,
      write_message.data,
      write_message.metadata
    )
  ;

  RAISE NOTICE 'Write Message';
  RAISE NOTICE 'ID ($1): %', write_message.id;
  RAISE NOTICE 'Stream Name ($2): %', write_message.stream_name;
  RAISE NOTICE 'Type ($3): %', write_message.type;
  RAISE NOTICE 'Data ($4): %', write_message.data;
  RAISE NOTICE 'Metadata ($5): %', write_message.metadata;
  RAISE NOTICE 'Expected Version ($6): %', write_message.expected_version;

  return _position;
END;
$$ LANGUAGE plpgsql
VOLATILE;
