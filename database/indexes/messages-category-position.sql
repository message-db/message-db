DROP INDEX IF EXISTS message_store.messages_category_position;

CREATE INDEX messages_category_position ON message_store.messages (
    message_store.category (stream_name),
    global_position
);
