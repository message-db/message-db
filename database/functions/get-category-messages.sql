CREATE OR REPLACE FUNCTION get_category_messages(
  category_name varchar,
  "position" bigint DEFAULT 1,
  batch_size bigint DEFAULT 1000,
  correlation varchar DEFAULT NULL,
  consumer_group_member bigint DEFAULT NULL,
  consumer_group_size bigint DEFAULT NULL,
  condition varchar DEFAULT NULL
)
RETURNS SETOF category_message
AS $$
DECLARE
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
      time::timestamp,
      hash_64(stream_name)::bigint AS stream_name_hash,
      (hash_64(stream_name) % $6)::bigint AS stream_name_modulo
    FROM
      messages
    WHERE
      category(stream_name) = $1 AND
      global_position >= $2';

  if get_category_messages.correlation is not null then
    if position('-' in get_category_messages.correlation) > 0 then
      RAISE EXCEPTION
       'Correlation must be a category (Correlation: %)',
        get_category_messages.correlation;
    end if;

    _command := _command || ' AND
      category(metadata->>''correlationStreamName'') = $4';
  end if;



  IF get_category_messages.consumer_group_member IS NOT NULL AND
      get_category_messages.consumer_group_size IS NOT NULL THEN

    _command := _command || ' AND
      @hash_64(stream_name) % $6 = $5';
  END IF;



  if get_category_messages.condition is not null then
    _command := _command || ' AND
      %s';
    _command := format(_command, get_category_messages.condition);
  end if;

  _command := _command || '
    ORDER BY
      global_position ASC
    LIMIT
      $3';

  if current_setting('message_store.debug_get', true) = 'on' OR current_setting('message_store.debug', true) = 'on' then
    RAISE NOTICE '» get_category_messages';
    RAISE NOTICE 'category_name ($1): %', get_category_messages.category_name;
    RAISE NOTICE 'position ($2): %', get_category_messages.position;
    RAISE NOTICE 'batch_size ($3): %', get_category_messages.batch_size;
    RAISE NOTICE 'correlation ($4): %', get_category_messages.correlation;
    RAISE NOTICE 'consumer_group_member ($5): %', get_category_messages.consumer_group_member;
    RAISE NOTICE 'consumer_group_size ($6): %', get_category_messages.consumer_group_size;
    RAISE NOTICE 'hash_64(category): %', hash_64(get_category_messages.category_name);
    RAISE NOTICE 'condition: %', get_category_messages.condition;
    RAISE NOTICE 'Generated Command: %', _command;
  end if;

  RETURN QUERY EXECUTE _command USING
    get_category_messages.category_name,
    get_category_messages.position,
    get_category_messages.batch_size,
    get_category_messages.correlation,
    get_category_messages.consumer_group_member,
    get_category_messages.consumer_group_size;
END;
$$ LANGUAGE plpgsql
VOLATILE;
