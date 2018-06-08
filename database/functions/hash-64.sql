CREATE OR REPLACE FUNCTION hash_64(
  _stream_name varchar
)
RETURNS bigint
AS $$
DECLARE
  hash bigint;
BEGIN
  select left('x' || md5(_stream_name), 16)::bit(64)::bigint into hash;
  return hash;
END;
$$ LANGUAGE plpgsql
IMMUTABLE;
