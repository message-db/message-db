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
    WITH
      type_count AS (
        SELECT
          type,
          COUNT(id) AS message_count
        FROM
          messages
        GROUP BY
          type
      ),

      total_count AS (
        SELECT
          COUNT(id)::decimal AS total_count
        FROM
          messages
      )

    SELECT
      type,
      message_count,
      ROUND((message_count / total_count)::decimal * 100, 2) AS percent
    FROM
      type_count,
      total_count';

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
