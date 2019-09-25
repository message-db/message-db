CREATE OR REPLACE FUNCTION stream_version(
  stream_name varchar
)
RETURNS bigint
AS $$
DECLARE
  _stream_version bigint;
BEGIN
  select
    max(position) into _stream_version
  from
    messages
  where
    messages.stream_name = stream_version.stream_name;

  return _stream_version;
END;
$$ LANGUAGE plpgsql
VOLATILE;
