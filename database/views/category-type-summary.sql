CREATE OR REPLACE VIEW category_type_summary AS
  WITH
    type_count AS (
      SELECT
        category(stream_name) as category,
        type,
        COUNT(id) AS message_count
      FROM
        messages
      GROUP BY
        category,
        type
    ),

    total_count AS (
      SELECT
        COUNT(id)::decimal AS total_count
      FROM
        messages
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
