#!/usr/bin/env bash

echo
echo "GET STREAM MESSAGES"
echo "==================="
echo

source test/stream-name.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

STREAM_NAME=$stream_name INSTANCES=3 database/write-test-message.sh > /dev/null

cmd="SELECT * FROM get_stream_messages('$stream_name', 0, 2, _condition => 'position >= 1');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
