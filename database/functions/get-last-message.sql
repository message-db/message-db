CREATE OR REPLACE FUNCTION get_last_message(
  stream_name varchar
)
RETURNS SETOF message
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
      messages
    WHERE
      stream_name = $1
    ORDER BY
      position DESC
    LIMIT
      1';

  -- RAISE NOTICE '%', _command;

  RETURN QUERY EXECUTE _command USING get_last_message.stream_name;
END;
$$ LANGUAGE plpgsql
VOLATILE;
