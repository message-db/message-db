CREATE OR REPLACE FUNCTION message_store.is_category(
  stream_name varchar
)
RETURNS boolean
AS $$
BEGIN
  IF NOT STRPOS(is_category.stream_name, '-') = 0 THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=message_store,public,pg_temp
IMMUTABLE;
