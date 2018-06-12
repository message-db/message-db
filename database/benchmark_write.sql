CREATE OR REPLACE FUNCTION benchmark_write(
  _stream_name varchar,
  _cycles int DEFAULT 1000
)
RETURNS void
AS $$
BEGIN
  FOR i IN 1.._cycles LOOP
    -- RAISE NOTICE '%', i;
    PERFORM write_message(gen_random_uuid()::varchar, _stream_name::varchar, 'SomeType'::varchar, '{"attribute": "some value"}'::jsonb, '{"metaAttribute": "some meta value"}'::jsonb);
  END LOOP;
END;
$$ LANGUAGE plpgsql
VOLATILE;



