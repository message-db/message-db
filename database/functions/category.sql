CREATE OR REPLACE FUNCTION category(
  _stream_name varchar
)
RETURNS varchar
AS $$
BEGIN
  return split_part(_stream_name, '-', 1);
END;
$$ LANGUAGE plpgsql
IMMUTABLE;
