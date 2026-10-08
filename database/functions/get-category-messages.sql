CREATE OR REPLACE FUNCTION message_store.get_category_messages(
  category varchar,
  transaction_position bigint DEFAULT 0,
  global_position bigint DEFAULT 0,
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
  IF NOT is_category(get_category_messages.category) THEN
    RAISE EXCEPTION
      'Must be a category: %',
      get_category_messages.category;
  END IF;

  transaction_position := COALESCE(transaction_position, 0);
  global_position := COALESCE(global_position, 0);
  batch_size := COALESCE(batch_size, 1000);

  -- Only publish transactions older than every transaction still in progress.
  -- Together with the tuple cursor, this prevents late commits being skipped.
  _command := '
    SELECT
      id::varchar,
      stream_name::varchar,
      type::varchar,
      position::bigint,
      transaction_id::xid8,
      global_position::bigint,
      data::varchar,
      metadata::varchar,
      time::timestamp
    FROM
      messages
    WHERE
      category(stream_name) = $1 AND
      (transaction_id, global_position) >= ($2::text::xid8, $3) AND
      transaction_id < pg_snapshot_xmin(pg_current_snapshot())';

  IF get_category_messages.correlation IS NOT NULL THEN
    IF position('-' IN get_category_messages.correlation) > 0 THEN
      RAISE EXCEPTION
        'Correlation must be a category (Correlation: %)',
        get_category_messages.correlation;
    END IF;

    _command := _command || ' AND
      category(metadata->>''correlationStreamName'') = $5';
  END IF;

  IF (get_category_messages.consumer_group_member IS NOT NULL AND
      get_category_messages.consumer_group_size IS NULL) OR
      (get_category_messages.consumer_group_member IS NULL AND
      get_category_messages.consumer_group_size IS NOT NULL) THEN

    RAISE EXCEPTION
      'Consumer group member and size must be specified (Consumer Group Member: %, Consumer Group Size: %)',
      get_category_messages.consumer_group_member,
      get_category_messages.consumer_group_size;
  END IF;

  IF get_category_messages.consumer_group_member IS NOT NULL AND
      get_category_messages.consumer_group_size IS NOT NULL THEN

    IF get_category_messages.consumer_group_size < 1 THEN
      RAISE EXCEPTION
        'Consumer group size must not be less than 1 (Consumer Group Member: %, Consumer Group Size: %)',
        get_category_messages.consumer_group_member,
        get_category_messages.consumer_group_size;
    END IF;

    IF get_category_messages.consumer_group_member < 0 THEN
      RAISE EXCEPTION
        'Consumer group member must not be less than 0 (Consumer Group Member: %, Consumer Group Size: %)',
        get_category_messages.consumer_group_member,
        get_category_messages.consumer_group_size;
    END IF;

    IF get_category_messages.consumer_group_member >= get_category_messages.consumer_group_size THEN
      RAISE EXCEPTION
        'Consumer group member must be less than the group size (Consumer Group Member: %, Consumer Group Size: %)',
        get_category_messages.consumer_group_member,
        get_category_messages.consumer_group_size;
    END IF;

    _command := _command || ' AND
      MOD(@hash_64(cardinal_id(stream_name)), $7) = $6';
  END IF;

  IF get_category_messages.condition IS NOT NULL THEN
    IF current_setting('message_store.sql_condition', true) IS NULL OR
        current_setting('message_store.sql_condition', true) = 'off' THEN
      RAISE EXCEPTION
        'Retrieval with SQL condition is not activated';
    END IF;

    _command := _command || ' AND
      (%s)';
    _command := format(_command, get_category_messages.condition);
  END IF;

  _command := _command || '
    ORDER BY
      transaction_id, global_position ASC';

  IF get_category_messages.batch_size != -1 THEN
    _command := _command || '
      LIMIT
        $4';
  END IF;

  IF current_setting('message_store.debug_get', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
    RAISE NOTICE '» get_category_messages';
    RAISE NOTICE 'category ($1): %', get_category_messages.category;
    RAISE NOTICE 'transaction_position ($2): %', get_category_messages.transaction_position;
    RAISE NOTICE 'global_position ($3): %', get_category_messages.global_position;
    RAISE NOTICE 'batch_size ($4): %', get_category_messages.batch_size;
    RAISE NOTICE 'correlation ($5): %', get_category_messages.correlation;
    RAISE NOTICE 'consumer_group_member ($6): %', get_category_messages.consumer_group_member;
    RAISE NOTICE 'consumer_group_size ($7): %', get_category_messages.consumer_group_size;
    RAISE NOTICE 'condition: %', get_category_messages.condition;
    RAISE NOTICE 'Generated Command: %', _command;
  END IF;

  RETURN QUERY EXECUTE _command USING
    get_category_messages.category,
    get_category_messages.transaction_position,
    get_category_messages.global_position,
    get_category_messages.batch_size,
    get_category_messages.correlation,
    get_category_messages.consumer_group_member,
    get_category_messages.consumer_group_size::smallint;
END;
$$ LANGUAGE plpgsql
VOLATILE;
