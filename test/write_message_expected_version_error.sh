#!/usr/bin/env bash

test/interactive/database/recreate_database.sh

STREAM_NAME=someStream-123 INSTANCES=4 tools/write_message.rb

psql message_store -c "SELECT write_message(gen_random_uuid()::varchar, 'someStream-123'::varchar, 'SomeType'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb, 4::bigint);"
