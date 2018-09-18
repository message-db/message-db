DO $$
BEGIN
  CREATE ROLE message_store;
EXCEPTION
  WHEN duplicate_object THEN
      RAISE NOTICE 'The message_store role already exists';
END$$;
