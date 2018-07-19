CREATE OR REPLACE FUNCTION get_stream_summary(
  _stream_name varchar DEFAULT NULL
)
RETURNS TABLE (
  stream_name varchar,
  message_count bigint,
  percent decimal
)
AS $$
DECLARE
  command text;
BEGIN
  command := '
    WITH
      stream_count AS (
        SELECT
          stream_name,
          COUNT(id) AS message_count
        FROM
          messages
        GROUP BY
          stream_name
      ),

      total_count AS (
        SELECT
          COUNT(id)::decimal AS total_count
        FROM
          messages
      )

    SELECT
      stream_name,
      message_count,
      ROUND((message_count / total_count)::decimal * 100, 2) AS percent
    FROM
      stream_count,
      total_count';

  IF _stream_name is not null THEN
    _stream_name := '%' || _stream_name || '%';
    command := command || '
    WHERE
      stream_name LIKE $1';
  END IF;

  command := command || '
    ORDER BY
      message_count DESC';

  -- RAISE NOTICE '%', command;

  IF _stream_name is not null THEN
    RETURN QUERY EXECUTE command USING _stream_name;
  ELSE
    RETURN QUERY EXECUTE command;
  END IF;
END;
$$ LANGUAGE plpgsql
VOLATILE;
