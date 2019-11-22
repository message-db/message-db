CREATE OR REPLACE FUNCTION category(
  stream_name varchar
)
RETURNS varchar
AS $$
BEGIN
  RETURN SPLIT_PART(category.stream_name, '-', 1);
END;
$$ LANGUAGE plpgsql
IMMUTABLE;
