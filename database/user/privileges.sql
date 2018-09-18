GRANT SELECT, INSERT ON messages TO message_store;

GRANT USAGE, SELECT ON SEQUENCE messages_global_position_seq TO message_store;

GRANT EXECUTE ON FUNCTION gen_random_uuid TO message_store;
GRANT EXECUTE ON FUNCTION md5(text) TO message_store;
GRANT EXECUTE ON FUNCTION hash_64 TO message_store;
GRANT EXECUTE ON FUNCTION category TO message_store;
GRANT EXECUTE ON FUNCTION stream_version TO message_store;
GRANT EXECUTE ON FUNCTION write_message TO message_store;
GRANT EXECUTE ON FUNCTION get_stream_messages TO message_store;
GRANT EXECUTE ON FUNCTION get_category_messages TO message_store;
GRANT EXECUTE ON FUNCTION get_last_message TO message_store;
