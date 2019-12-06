CREATE OR REPLACE FUNCTION message_store.hash_64(
  value varchar
)
RETURNS bigint
AS $$
DECLARE
  _hash bigint;
BEGIN
  SELECT left('x' || md5(hash_64.value), 17)::bit(64)::bigint INTO _hash;
  return _hash;
END;
$$ LANGUAGE plpgsql
IMMUTABLE;
