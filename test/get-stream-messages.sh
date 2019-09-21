#!/usr/bin/env bash

echo
echo "GET STREAM MESSAGES"
echo "==================="
echo "- Write 3 messages to an entity stream"
echo "- Retrieve a batch of 2 messages, starting at position 0 where the position is greater than or equal to 1"
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
