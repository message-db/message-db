#!/usr/bin/env bash

instances = Integer(ENV['INSTANCES'] || 1)
stream_name = ENV['STREAM_NAME']



psql message_store -c "SELECT write_message(gen_random_uuid()::varchar, 'testWriteIsolation'::varchar, 'SomeType'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb);"
