CREATE OR REPLACE FUNCTION message_store.get_all_messages(
  "position" bigint DEFAULT 1,
  batch_size bigint DEFAULT 1000,
  correlation varchar DEFAULT NULL,
  consumer_group_member bigint DEFAULT NULL,
  consumer_group_size bigint DEFAULT NULL,
  condition varchar DEFAULT NULL
)
RETURNS SETOF message_store.message
AS $$
DECLARE
  _command text;
BEGIN
  position := COALESCE(position, 1);
  batch_size := COALESCE(batch_size, 1000);

  _command := '
    SELECT
      id::varchar,
      stream_name::varchar,
      type::varchar,
      position::bigint,
      global_position::bigint,
      data::varchar,
      metadata::varchar,
      time::timestamp
    FROM
      messages
    WHERE
      global_position >= $1';

  IF get_all_messages.correlation IS NOT NULL THEN
    IF position('-' IN get_all_messages.correlation) > 0 THEN
      RAISE EXCEPTION
        'Correlation must be a category (Correlation: %)',
        get_all_messages.correlation;
    END IF;

    _command := _command || ' AND
      category(metadata->>''correlationStreamName'') = $3';
  END IF;

  IF (get_all_messages.consumer_group_member IS NOT NULL AND
      get_all_messages.consumer_group_size IS NULL) OR
      (get_all_messages.consumer_group_member IS NULL AND
      get_all_messages.consumer_group_size IS NOT NULL) THEN

    RAISE EXCEPTION
      'Consumer group member and size must be specified (Consumer Group Member: %, Consumer Group Size: %)',
      get_all_messages.consumer_group_member,
      get_all_messages.consumer_group_size;
  END IF;

  IF get_all_messages.consumer_group_member IS NOT NULL AND
      get_all_messages.consumer_group_size IS NOT NULL THEN

    IF get_all_messages.consumer_group_size < 1 THEN
      RAISE EXCEPTION
        'Consumer group size must not be less than 1 (Consumer Group Member: %, Consumer Group Size: %)',
        get_all_messages.consumer_group_member,
        get_all_messages.consumer_group_size;
    END IF;

    IF get_all_messages.consumer_group_member < 0 THEN
      RAISE EXCEPTION
        'Consumer group member must not be less than 0 (Consumer Group Member: %, Consumer Group Size: %)',
        get_all_messages.consumer_group_member,
        get_all_messages.consumer_group_size;
    END IF;

    IF get_all_messages.consumer_group_member >= get_all_messages.consumer_group_size THEN
      RAISE EXCEPTION
        'Consumer group member must be less than the group size (Consumer Group Member: %, Consumer Group Size: %)',
        get_all_messages.consumer_group_member,
        get_all_messages.consumer_group_size;
    END IF;

    _command := _command || ' AND
      MOD(@hash_64(cardinal_id(stream_name)), $5) = $4';
  END IF;

  IF get_all_messages.condition IS NOT NULL THEN
    IF current_setting('message_store.sql_condition', true) IS NULL OR
        current_setting('message_store.sql_condition', true) = 'off' THEN
      RAISE EXCEPTION
        'Retrieval with SQL condition is not activated';
    END IF;

    _command := _command || ' AND
      (%s)';
    _command := format(_command, get_all_messages.condition);
  END IF;

  _command := _command || '
    ORDER BY
      global_position ASC';

  IF get_all_messages.batch_size != -1 THEN
    _command := _command || '
      LIMIT
        $2';
  END IF;

  IF current_setting('message_store.debug_get', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
    RAISE NOTICE '» get_all_messages';
    RAISE NOTICE 'position ($1): %', get_all_messages.position;
    RAISE NOTICE 'batch_size ($2): %', get_all_messages.batch_size;
    RAISE NOTICE 'correlation ($3): %', get_all_messages.correlation;
    RAISE NOTICE 'consumer_group_member ($4): %', get_all_messages.consumer_group_member;
    RAISE NOTICE 'consumer_group_size ($5): %', get_all_messages.consumer_group_size;
    RAISE NOTICE 'condition: %', get_all_messages.condition;
    RAISE NOTICE 'Generated Command: %', _command;
  END IF;

  RETURN QUERY EXECUTE _command USING
    get_all_messages.position,
    get_all_messages.batch_size,
    get_all_messages.correlation,
    get_all_messages.consumer_group_member,
    get_all_messages.consumer_group_size::smallint;
END;
$$ LANGUAGE plpgsql
VOLATILE;
