CREATE OR REPLACE VIEW message_store.stream_summary AS
  WITH
    stream_count AS (
      SELECT
        stream_name,
        COUNT(id) AS message_count
      FROM
        message_store.messages
      GROUP BY
        stream_name
    ),

    total_count AS (
      SELECT
        COUNT(id)::decimal AS total_count
      FROM
        message_store.messages
    )

  SELECT
    stream_name,
    message_count,
    ROUND((message_count / total_count)::decimal * 100, 2) AS percent
  FROM
    stream_count,
    total_count
  ORDER BY
    stream_name;
