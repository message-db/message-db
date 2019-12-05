CREATE OR REPLACE FUNCTION message_store.stream_version(
  stream_name varchar
)
RETURNS bigint
AS $$
DECLARE
  _stream_version bigint;
BEGIN
  SELECT
    max(position) into _stream_version
  FROM
    messages
  WHERE
    messages.stream_name = stream_version.stream_name;

  RETURN _stream_version;
END;
$$ LANGUAGE plpgsql
VOLATILE;
