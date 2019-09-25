CREATE OR REPLACE FUNCTION get_stream_messages(
  stream_name varchar,
  "position" bigint DEFAULT 0,
  batch_size bigint DEFAULT 1000,
  condition varchar DEFAULT NULL
)
RETURNS SETOF message
AS $$
DECLARE
  command text;
BEGIN
  command := '
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
    command := command || ' AND
      %s';
    command := format(command, get_stream_messages.condition);
  end if;

  command := command || '
    ORDER BY
      position ASC
    LIMIT
      $3';

  -- RAISE NOTICE '%', command;

  RETURN QUERY EXECUTE command USING
    get_stream_messages.stream_name,
    get_stream_messages.position,
    get_stream_messages.batch_size;
END;
$$ LANGUAGE plpgsql
VOLATILE;
