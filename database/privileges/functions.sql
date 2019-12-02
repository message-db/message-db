GRANT EXECUTE ON FUNCTION gen_random_uuid() TO message_store;
GRANT EXECUTE ON FUNCTION md5(text) TO message_store;
GRANT EXECUTE ON FUNCTION hash_64(varchar) TO message_store;
GRANT EXECUTE ON FUNCTION category(varchar) TO message_store;
GRANT EXECUTE ON FUNCTION stream_version(varchar) TO message_store;
GRANT EXECUTE ON FUNCTION write_message(varchar, varchar, varchar, jsonb, jsonb, bigint) TO message_store;
GRANT EXECUTE ON FUNCTION get_stream_messages(varchar, bigint, bigint, varchar) TO message_store;
GRANT EXECUTE ON FUNCTION get_category_messages(varchar, bigint, bigint, varchar, bigint, bigint, varchar) TO message_store;
GRANT EXECUTE ON FUNCTION get_last_stream_message(varchar) TO message_store;
