CREATE OR REPLACE FUNCTION get_stream_messages(
  stream_name varchar,
  "position" bigint DEFAULT 0,
  batch_size bigint DEFAULT 1000,
  condition varchar DEFAULT NULL
)
RETURNS SETOF message
AS $$
DECLARE
  _command text;
BEGIN
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

  if get_stream_messages.condition is not null then
    _command := _command || ' AND
      %s';
    _command := format(_command, get_stream_messages.condition);
  end if;

  _command := _command || '
    ORDER BY
      position ASC
    LIMIT
      $3';

  RAISE NOTICE '%', _command;
  RAISE NOTICE 'Stream Name ($1): %', get_stream_messages.stream_name;
  RAISE NOTICE 'Position ($2): %', get_stream_messages.position;
  RAISE NOTICE 'Batch Size ($3): %', get_stream_messages.batch_size;
  RAISE NOTICE 'Condition ($4): %', get_stream_messages.condition;

  RETURN QUERY EXECUTE _command USING
    get_stream_messages.stream_name,
    get_stream_messages.position,
    get_stream_messages.batch_size;
END;
$$ LANGUAGE plpgsql
VOLATILE;
