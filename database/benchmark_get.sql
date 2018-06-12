CREATE OR REPLACE FUNCTION benchmark_get(
  _stream_name varchar,
  _cycles int DEFAULT 1000
)
RETURNS void
AS $$
BEGIN
  FOR i IN 1.._cycles LOOP
    -- RAISE NOTICE '%', i;
    PERFORM * FROM get_stream_messages(_stream_name, _batch_size => 1);
  END LOOP;
END;
$$ LANGUAGE plpgsql
VOLATILE;



