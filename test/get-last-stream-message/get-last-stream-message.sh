#!/usr/bin/env bash

set -e

echo
echo "GET LAST MESSAGE"
echo "================"
echo "- Write 2 messages to an entity stream"
echo "- Retrieve the last message in the stream"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

STREAM_NAME=$stream_name INSTANCES=2 database/write-test-message.sh > /dev/null

cmd="SELECT * FROM get_last_stream_message('$stream_name');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
