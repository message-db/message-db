CREATE OR REPLACE FUNCTION message_store.get_stream_messages(
  stream_name varchar,
  "position" bigint DEFAULT 0,
  batch_size bigint DEFAULT 1000,
  condition varchar DEFAULT NULL
)
RETURNS SETOF message_store.message
AS $$
DECLARE
  _command text;
  _setting text;
BEGIN
  IF is_category(get_stream_messages.stream_name) THEN
    RAISE EXCEPTION
      'Must be a stream name: %',
      get_stream_messages.stream_name;
  END IF;

  position := COALESCE(position, 0);
  batch_size := COALESCE(batch_size, 1000);

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
      messages
    WHERE
      stream_name = $1 AND
      position >= $2';

  IF get_stream_messages.condition IS NOT NULL THEN
    IF current_setting('message_store.sql_condition', true) IS NULL OR
        current_setting('message_store.sql_condition', true) = 'off' THEN
      RAISE EXCEPTION
        'Retrieval with SQL condition is not activated';
    END IF;

    _command := _command || ' AND
      (%s)';
    _command := format(_command, get_stream_messages.condition);
  END IF;

  _command := _command || '
    ORDER BY
      position ASC';

  IF get_stream_messages.batch_size != -1 THEN
    _command := _command || '
      LIMIT
        $3';
  END IF;

  IF current_setting('message_store.debug_get', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
    RAISE NOTICE '» get_stream_messages';
    RAISE NOTICE 'stream_name ($1): %', get_stream_messages.stream_name;
    RAISE NOTICE 'position ($2): %', get_stream_messages.position;
    RAISE NOTICE 'batch_size ($3): %', get_stream_messages.batch_size;
    RAISE NOTICE 'condition ($4): %', get_stream_messages.condition;
    RAISE NOTICE 'Generated Command: %', _command;
  END IF;

  RETURN QUERY EXECUTE _command USING
    get_stream_messages.stream_name,
    get_stream_messages.position,
    get_stream_messages.batch_size;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=message_store,public,pg_temp
VOLATILE;
