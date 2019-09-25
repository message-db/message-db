CREATE OR REPLACE FUNCTION get_category_messages(
  category_name varchar,
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
      category(stream_name) = $1 AND
      global_position >= $2';

  if get_category_messages.condition is not null then
    command := command || ' AND
      %s';
    command := format(command, get_category_messages.condition);
  end if;

  command := command || '
    ORDER BY
      global_position ASC
    LIMIT
      $3';

  -- RAISE NOTICE '%', command;

  RETURN QUERY EXECUTE command USING get_category_messages.category_name, get_category_messages.position, get_category_messages.batch_size;
END;
$$ LANGUAGE plpgsql
VOLATILE;
