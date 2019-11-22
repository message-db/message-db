CREATE OR REPLACE FUNCTION first_id(
  stream_name varchar
)
RETURNS varchar[]
AS $$
DECLARE
  _id varchar;
BEGIN
  _id := id(first_id.stream_name);

  IF _id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN SPLIT_PART(_id, '+', 1);
END;
$$ LANGUAGE plpgsql
IMMUTABLE;
