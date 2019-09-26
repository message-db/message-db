CREATE OR REPLACE FUNCTION category(
  stream_name varchar
)
RETURNS varchar
AS $$
BEGIN
  return split_part(category.stream_name, '-', 1);
END;
$$ LANGUAGE plpgsql
IMMUTABLE;
