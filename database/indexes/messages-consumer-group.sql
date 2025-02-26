DROP INDEX IF EXISTS message_store.messages_consumer_group;

CREATE INDEX messages_consumer_group ON message_store.messages (message_store.cardinal_id (stream_name));
