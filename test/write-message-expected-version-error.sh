#!/usr/bin/env bash

set -e

echo
echo "WRITE MESSAGE - EXPECTED VERSION ERROR"
echo "======================================"
echo "- Write a single message to an entity stream"
echo "- Write another message with the expected version of 1 that does not match a stream with one message"
echo "- Terminates with an error"
echo

source test/controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

write-message $stream_name

cmd="SELECT write_message(gen_random_uuid()::varchar, '$stream_name'::varchar, 'SomeType'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb, 1::bigint);"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -x -c "$cmd"
set -e

echo "= = ="
echo
