CREATE OR REPLACE FUNCTION message_store.write_message(
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
  _next_position bigint;
BEGIN
  PERFORM acquire_lock(write_message.stream_name);

  _stream_version := stream_version(write_message.stream_name);

  IF _stream_version IS NULL THEN
    _stream_version := -1;
  END IF;

  IF write_message.expected_version IS NOT NULL THEN
    IF write_message.expected_version != _stream_version THEN
      RAISE EXCEPTION
        'Wrong expected version: % (Stream: %, Stream Version: %)',
        write_message.expected_version,
        write_message.stream_name,
        _stream_version;
    END IF;
  END IF;

  _next_position := _stream_version + 1;

  _message_id = uuid(write_message.id);

  INSERT INTO messages
    (
      id,
      stream_name,
      position,
      type,
      data,
      metadata
    )
  VALUES
    (
      _message_id,
      write_message.stream_name,
      _next_position,
      write_message.type,
      write_message.data,
      write_message.metadata
    )
  ;

  IF current_setting('message_store.debug_write', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
    RAISE NOTICE '» write_message';
    RAISE NOTICE 'id ($1): %', write_message.id;
    RAISE NOTICE 'stream_name ($2): %', write_message.stream_name;
    RAISE NOTICE 'type ($3): %', write_message.type;
    RAISE NOTICE 'data ($4): %', write_message.data;
    RAISE NOTICE 'metadata ($5): %', write_message.metadata;
    RAISE NOTICE 'expected_version ($6): %', write_message.expected_version;
    RAISE NOTICE '_stream_version: %', _stream_version;
    RAISE NOTICE '_next_position: %', _next_position;
  END IF;

  RETURN _next_position;
END;
$$ LANGUAGE plpgsql
VOLATILE;
