CREATE OR REPLACE FUNCTION message_store.get_last_stream_message(
  stream_name varchar,
  type varchar DEFAULT NULL
)
RETURNS SETOF message_store.message
AS $$
DECLARE
  _command text;
BEGIN
  _command := '
    SELECT
      id::varchar,
      stream_name::varchar,
      type::varchar,
      position::bigint,
      global_position::bigint,
      data::varchar,
      metadata::varchar,
      time::timestamp
    FROM
      message_store.messages
    WHERE
      stream_name = $1';

  IF get_last_stream_message.type IS NOT NULL THEN
    _command := _command || ' AND
      type = $2';
  END IF;

  _command := _command || '
    ORDER BY
      position DESC
    LIMIT
      1';

  IF current_setting('message_store.debug_get', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
    RAISE NOTICE '» get_last_message';
    RAISE NOTICE 'stream_name ($1): %', get_last_stream_message.stream_name;
    RAISE NOTICE 'type ($2): %', get_last_stream_message.type;
    RAISE NOTICE 'Generated Command: %', _command;
  END IF;

  RETURN QUERY EXECUTE _command USING
    get_last_stream_message.stream_name,
    get_last_stream_message.type;
END;
$$ LANGUAGE plpgsql
VOLATILE;
