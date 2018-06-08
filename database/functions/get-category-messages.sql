CREATE OR REPLACE FUNCTION get_category_messages(
  _stream_name varchar,
  _position bigint DEFAULT 0,
  _batch_size bigint DEFAULT 1000,
  _condition varchar DEFAULT NULL
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
      category(stream_name) = $1 AND
      global_position >= $2';

  if _condition is not null then
    command := command || ' AND
      %s';
    command := format(command, _condition);
  end if;

  command := command || '
    ORDER BY
      global_position ASC
    LIMIT
      $3';

  -- RAISE NOTICE '%', command;

  RETURN QUERY EXECUTE command USING _stream_name, _position, _batch_size;
END;
$$ LANGUAGE plpgsql
VOLATILE;
