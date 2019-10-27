-- Table
GRANT SELECT, INSERT ON messages TO message_store;

-- Sequence
GRANT USAGE, SELECT ON SEQUENCE messages_global_position_seq TO message_store;

-- Functions
GRANT EXECUTE ON FUNCTION gen_random_uuid() TO message_store;
GRANT EXECUTE ON FUNCTION md5(text) TO message_store;
GRANT EXECUTE ON FUNCTION hash_64(varchar) TO message_store;
GRANT EXECUTE ON FUNCTION category(varchar) TO message_store;
GRANT EXECUTE ON FUNCTION stream_version(varchar) TO message_store;
GRANT EXECUTE ON FUNCTION write_message(varchar, varchar, varchar, jsonb, jsonb, bigint) TO message_store;
GRANT EXECUTE ON FUNCTION get_stream_messages(varchar, bigint, bigint, varchar) TO message_store;
GRANT EXECUTE ON FUNCTION get_category_messages(varchar, bigint, bigint, varchar, varchar) TO message_store;
GRANT EXECUTE ON FUNCTION get_last_message(varchar) TO message_store;

-- Views
GRANT SELECT ON category_type_summary TO message_store;
GRANT SELECT ON stream_summary TO message_store;
GRANT SELECT ON stream_type_summary TO message_store;
GRANT SELECT ON type_category_summary TO message_store;
GRANT SELECT ON type_stream_summary TO message_store;
GRANT SELECT ON type_summary TO message_store;
