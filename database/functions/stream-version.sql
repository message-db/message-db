CREATE OR REPLACE FUNCTION message_store.stream_version(
  stream_name varchar
)
RETURNS bigint
AS $$
DECLARE
  _stream_version bigint;
BEGIN
  IF is_category(stream_version.stream_name) THEN
    RAISE EXCEPTION
      'Must be a stream name: %',
      stream_version.stream_name;
  END IF;

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
