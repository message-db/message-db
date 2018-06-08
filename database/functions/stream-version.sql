CREATE OR REPLACE FUNCTION stream_version(
  _stream_name varchar
)
RETURNS bigint
AS $$
DECLARE
  stream_version bigint;
BEGIN
  select max(position) into stream_version from messages where stream_name = _stream_name;

  return stream_version;
END;
$$ LANGUAGE plpgsql
VOLATILE;
