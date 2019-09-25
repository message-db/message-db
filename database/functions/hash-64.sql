CREATE OR REPLACE FUNCTION hash_64(
  stream_name varchar
)
RETURNS bigint
AS $$
DECLARE
  hash bigint;
BEGIN
  select left('x' || md5(hash_64.stream_name), 17)::bit(64)::bigint into hash;
  return hash;
END;
$$ LANGUAGE plpgsql
IMMUTABLE;
