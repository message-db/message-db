CREATE OR REPLACE FUNCTION get_last_message(
  stream_name varchar
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
      stream_name = $1
    ORDER BY
      position DESC
    LIMIT
      1';

  -- RAISE NOTICE '%', command;

  RETURN QUERY EXECUTE command USING get_last_message.stream_name;
END;
$$ LANGUAGE plpgsql
VOLATILE;
