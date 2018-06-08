#!/usr/bin/env bash

psql message_store -c "SELECT write_message(gen_random_uuid()::varchar, 'testWriteIsolation'::varchar, 'SomeType'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb);"
