CREATE OR REPLACE FUNCTION get_stream_messages(
  stream_name varchar,
  "position" bigint DEFAULT 0,
  batch_size bigint DEFAULT 1000,
  correlation varchar DEFAULT NULL,
  condition varchar DEFAULT NULL
)
RETURNS SETOF message
AS $$
DECLARE
  _command text;
BEGIN
  IF position('-' IN get_stream_messages.stream_name) = 0 THEN
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

  IF get_stream_messages.correlation IS NOT NULL THEN
    IF position('-' IN get_stream_messages.correlation) > 0 THEN
      RAISE EXCEPTION
       'Correlation must be a category (Correlation: %)',
        get_stream_messages.correlation;
    END IF;

    _command := _command || ' AND
      category(metadata->>''correlationStreamName'') = $4';
  END IF;

  IF get_stream_messages.condition IS NOT NULL THEN
    _command := _command || ' AND
      %s';
    _command := format(_command, get_stream_messages.condition);
  END IF;

  _command := _command || '
    ORDER BY
      position ASC
    LIMIT
      $3';

  IF current_setting('message_store.debug_get', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
    RAISE NOTICE '» get_stream_messages';
    RAISE NOTICE 'stream_name ($1): %', get_stream_messages.stream_name;
    RAISE NOTICE 'position ($2): %', get_stream_messages.position;
    RAISE NOTICE 'batch_size ($3): %', get_stream_messages.batch_size;
    RAISE NOTICE 'correlation ($4): %', get_stream_messages.correlation;
    RAISE NOTICE 'condition ($5): %', get_stream_messages.condition;
    RAISE NOTICE 'Generated Command: %', _command;
  end if;

  RETURN QUERY EXECUTE _command USING
    get_stream_messages.stream_name,
    get_stream_messages.position,
    get_stream_messages.batch_size,
    get_stream_messages.correlation;
END;
$$ LANGUAGE plpgsql
VOLATILE;
