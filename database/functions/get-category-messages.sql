CREATE OR REPLACE FUNCTION message_store.get_category_messages(
  category varchar,
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
  _result message_store.message;
BEGIN

  IF NOT is_category(get_category_messages.category) THEN
    RAISE EXCEPTION
      'Must be a category: %',
      get_category_messages.category;
  END IF;

  IF get_category_messages.correlation IS NOT NULL THEN
    IF position('-' IN get_category_messages.correlation) > 0 THEN
      RAISE EXCEPTION
        'Correlation must be a category (Correlation: %)',
        get_category_messages.correlation;
    END IF;
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
  END IF;

  IF get_category_messages.condition IS NOT NULL THEN
    IF current_setting('message_store.sql_condition', true) IS NULL OR
       current_setting('message_store.sql_condition', true) = 'off' THEN
      RAISE EXCEPTION
        'Retrieval with SQL condition is not activated';
    END IF;
  END IF;

  IF current_setting('message_store.debug_get', true) = 'on' OR current_setting('message_store.debug', true) = 'on' THEN
    RAISE NOTICE '» get_category_messages';
    RAISE NOTICE 'category: %', get_category_messages.category;
    RAISE NOTICE 'position: %', get_category_messages."position";
    RAISE NOTICE 'batch_size: %', get_category_messages.batch_size;
    RAISE NOTICE 'correlation: %', get_category_messages.correlation;
    RAISE NOTICE 'consumer_group_member: %', get_category_messages.consumer_group_member;
    RAISE NOTICE 'consumer_group_size: %', get_category_messages.consumer_group_size;
    RAISE NOTICE 'condition: %', get_category_messages.condition;
  END IF;

  -- Basic case - just category and position filtering
  IF get_category_messages.correlation IS NULL AND
     get_category_messages.consumer_group_member IS NULL AND
     get_category_messages.condition IS NULL THEN

    -- Standard query path (most common case)
    IF get_category_messages.batch_size != -1 THEN
      RETURN QUERY
      SELECT
        id::varchar,
        stream_name::varchar,
        type::varchar,
        messages.position::bigint,
        global_position::bigint,
        data::varchar,
        metadata::varchar,
        time::timestamp
      FROM
        messages
      WHERE
        message_store.category(stream_name) = get_category_messages.category AND
        global_position >= get_category_messages."position"
      ORDER BY
        global_position ASC
      LIMIT
        get_category_messages.batch_size;
    ELSE
      -- No limit case
      RETURN QUERY
      SELECT
        id::varchar,
        stream_name::varchar,
        type::varchar,
        messages.position::bigint,
        global_position::bigint,
        data::varchar,
        metadata::varchar,
        time::timestamp
      FROM
        messages
      WHERE
        message_store.category(stream_name) = get_category_messages.category AND
        global_position >= get_category_messages."position"
      ORDER BY
        global_position ASC;
    END IF;

    RETURN;
  END IF;

  -- Case with correlation but no consumer group or condition
  IF get_category_messages.correlation IS NOT NULL AND
     get_category_messages.consumer_group_member IS NULL AND
     get_category_messages.condition IS NULL THEN

    IF get_category_messages.batch_size != -1 THEN
      RETURN QUERY
      SELECT
        id::varchar,
        stream_name::varchar,
        type::varchar,
        messages.position::bigint,
        global_position::bigint,
        data::varchar,
        metadata::varchar,
        time::timestamp
      FROM
        messages
      WHERE
        message_store.category(stream_name) = get_category_messages.category AND
        global_position >= get_category_messages."position" AND
        message_store.category(metadata->>'correlationStreamName') = get_category_messages.correlation
      ORDER BY
        global_position ASC
      LIMIT
        get_category_messages.batch_size;
    ELSE
      -- No limit case
      RETURN QUERY
      SELECT
        id::varchar,
        stream_name::varchar,
        type::varchar,
        messages.position::bigint,
        global_position::bigint,
        data::varchar,
        metadata::varchar,
        time::timestamp
      FROM
        messages
      WHERE
        message_store.category(stream_name) = get_category_messages.category AND
        global_position >= get_category_messages."position" AND
        message_store.category(metadata->>'correlationStreamName') = get_category_messages.correlation
      ORDER BY
        global_position ASC;
    END IF;

    RETURN;
  END IF;

  -- Case with consumer group but no correlation or condition
  IF get_category_messages.correlation IS NULL AND
     get_category_messages.consumer_group_member IS NOT NULL AND
     get_category_messages.condition IS NULL THEN

    IF get_category_messages.batch_size != -1 THEN
      RETURN QUERY
      SELECT
        id::varchar,
        stream_name::varchar,
        type::varchar,
        messages.position::bigint,
        global_position::bigint,
        data::varchar,
        metadata::varchar,
        time::timestamp
      FROM
        messages
      WHERE
        message_store.category(stream_name) = get_category_messages.category AND
        global_position >= get_category_messages."position" AND
        MOD(@hash_64(message_store.cardinal_id(stream_name)), get_category_messages.consumer_group_size) = get_category_messages.consumer_group_member
      ORDER BY
        global_position ASC
      LIMIT
        get_category_messages.batch_size;
    ELSE
      -- No limit case
      RETURN QUERY
      SELECT
        id::varchar,
        stream_name::varchar,
        type::varchar,
        messages.position::bigint,
        global_position::bigint,
        data::varchar,
        metadata::varchar,
        time::timestamp
      FROM
        messages
      WHERE
        message_store.category(stream_name) = get_category_messages.category AND
        global_position >= get_category_messages."position" AND
        MOD(@hash_64(message_store.cardinal_id(stream_name)), get_category_messages.consumer_group_size) = get_category_messages.consumer_group_member
      ORDER BY
        global_position ASC;
    END IF;

    RETURN;
  END IF;

  RETURN QUERY
  SELECT * FROM message_store.get_category_messages_dynamic(
    get_category_messages.category,
    get_category_messages."position",
    get_category_messages.batch_size,
    get_category_messages.correlation,
    get_category_messages.consumer_group_member,
    get_category_messages.consumer_group_size,
    get_category_messages.condition);

END;
$$ LANGUAGE plpgsql VOLATILE PARALLEL SAFE;
