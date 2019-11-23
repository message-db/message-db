#!/usr/bin/env bash

set -e

echo
echo "WRITE MESSAGE - EXPECTED VERSION"
echo "================================"
echo "- Write a single message to an entity stream"
echo "- Write another message with the expected version of 0 that matches a stream with one message"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

write-message $stream_name

cmd="SELECT write_message(gen_random_uuid()::varchar, '$stream_name'::varchar, 'SomeType'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb, 0::bigint);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -x -c "$cmd"

echo "= = ="
echo
