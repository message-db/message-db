CREATE OR REPLACE FUNCTION benchmark_get(
  stream_name varchar,
  cycles int DEFAULT 1000
)
RETURNS void
AS $$
BEGIN
  RAISE NOTICE '» benchmark_get';
  RAISE NOTICE 'stream_name: %', benchmark_get.stream_name;
  RAISE NOTICE 'cycles: %', benchmark_get.cycles;

  FOR i IN 1..cycles LOOP
    -- RAISE NOTICE '%', i;
    PERFORM get_stream_messages(stream_name, "position" => i - 1, batch_size => 1);
  END LOOP;
END;
$$ LANGUAGE plpgsql
VOLATILE;



