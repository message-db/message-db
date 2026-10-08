CREATE OR REPLACE FUNCTION message_store.acquire_lock(
  stream_name varchar
)
RETURNS bigint
AS $$
DECLARE
  _stream_name_hash bigint;
BEGIN
  _stream_name_hash := hash_64(acquire_lock.stream_name);
  PERFORM pg_advisory_xact_lock(_stream_name_hash);

  IF current_setting('message_store.debug_write', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
    RAISE NOTICE '» acquire_lock';
    RAISE NOTICE 'stream_name: %', acquire_lock.stream_name;
    RAISE NOTICE '_stream_name_hash: %', _stream_name_hash;
  END IF;

  RETURN _stream_name_hash;
END;
$$ LANGUAGE plpgsql
VOLATILE;
