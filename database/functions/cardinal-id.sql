CREATE OR REPLACE FUNCTION message_store.cardinal_id(
  stream_name varchar
)
RETURNS varchar
AS $$
DECLARE
  _id varchar;
BEGIN
  _id := id(cardinal_id.stream_name);

  IF _id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN SPLIT_PART(_id, '+', 1);
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=message_store,public,pg_temp
IMMUTABLE;
