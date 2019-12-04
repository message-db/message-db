CREATE OR REPLACE VIEW message_store.category_type_summary AS
  WITH
    type_count AS (
      SELECT
        message_store.category(stream_name) AS category,
        type,
        COUNT(id) AS message_count
      FROM
        message_store.messages
      GROUP BY
        category,
        type
    ),

    total_count AS (
      SELECT
        COUNT(id)::decimal AS total_count
      FROM
        message_store.messages
    )

  SELECT
    category,
    type,
    message_count,
    ROUND((message_count / total_count)::decimal * 100, 2) AS percent
  FROM
    type_count,
    total_count
  ORDER BY
    category,
    type;
