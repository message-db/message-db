#!/usr/bin/env bash

echo
echo "WRITE MESSAGE EXPECTED VERSION"
echo "=============================="
echo

test/recreate_database.sh

STREAM_NAME=someStream-123 INSTANCES=4 test/write_message.sh

psql message_store -c "SELECT write_message(gen_random_uuid()::varchar, 'someStream-123'::varchar, 'SomeType'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb, 3::bigint);"

echo "= = ="
echo
