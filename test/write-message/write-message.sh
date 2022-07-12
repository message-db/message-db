#!/usr/bin/env bash

set -e

echo
echo "WRITE MESSAGE"
echo "============="
echo "Write a single message to an entity stream"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

type=$(type)

cmd="SELECT write_message(gen_random_uuid()::varchar, '$stream_name'::varchar, '$type'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -x -c "$cmd"

psql message_store -U message_store -P pager=off -x -c "SELECT * FROM messages WHERE stream_name = '$stream_name';"

echo "= = ="
echo
