DROP INDEX IF EXISTS message_store.messages_correlation;

CREATE INDEX messages_correlation ON message_store.messages (
    message_store.category (metadata->>'correlationStreamName')
);
