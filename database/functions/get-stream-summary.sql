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
  total_count bigint;
  command text;
BEGIN
  SELECT count(*) INTO total_count FROM messages;

  command := '
    SELECT
      stream_name,
      message_count,
      ROUND((SELECT (message_count::decimal / count(*)::decimal * 100.0) FROM messages)::decimal, 2) AS percent
    FROM
      (
        SELECT
          DISTINCT stream_name,
          count(stream_name) AS message_count
        FROM
          messages';

    command := command || '
        GROUP BY
          stream_name
      ) summary';


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
