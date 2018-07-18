CREATE OR REPLACE FUNCTION get_type_summary(
  _type varchar DEFAULT NULL
)
RETURNS TABLE (
  type varchar,
  message_count bigint,
  percent decimal
)
AS $$
DECLARE
  command text;
BEGIN
  command := '
    SELECT
      type,
      message_count,
      ROUND((SELECT (message_count::decimal / count(*)::decimal * 100.0) FROM messages)::decimal, 2) AS percent
    FROM
      (
        SELECT
          DISTINCT type,
          count(type) AS message_count
        FROM
          messages';

    command := command || '
        GROUP BY
          type
      ) summary';


  IF _type is not null THEN
    _type := '%' || _type || '%';
    command := command || '
    WHERE
      type LIKE $1';
  END IF;

  command := command || '
    ORDER BY
      message_count DESC';

  -- RAISE NOTICE '%', command;

  IF _type is not null THEN
    RETURN QUERY EXECUTE command USING _type;
  ELSE
    RETURN QUERY EXECUTE command;
  END IF;
END;
$$ LANGUAGE plpgsql
VOLATILE;
