CREATE OR REPLACE FUNCTION message_store_version()
RETURNS varchar
AS $$
BEGIN
  RETURN '2.0.0.0';
END;
$$ LANGUAGE plpgsql
VOLATILE;
