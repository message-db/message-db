CREATE OR REPLACE FUNCTION benchmark_write(
  stream_name varchar,
  cycles int DEFAULT 1000
)
RETURNS void
AS $$
BEGIN
  RAISE NOTICE '» benchmark_write';
  RAISE NOTICE 'stream_name: %', benchmark_write.stream_name;
  RAISE NOTICE 'cycles: %', benchmark_write.cycles;

  FOR i IN 1..cycles LOOP
    IF current_setting('message_store.debug_benchmark', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
      RAISE NOTICE '%', i;
    END IF;

    PERFORM write_message(gen_random_uuid()::varchar, stream_name::varchar, 'SomeType'::varchar, '{"attribute": "some value"}'::jsonb, '{"metaAttribute": "some meta value", "correlationStreamName": "someCorrelation-123"}'::jsonb);
  END LOOP;
END;
$$ LANGUAGE plpgsql
VOLATILE;



