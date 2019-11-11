#!/usr/bin/env bash

set -e

echo
echo "GET STREAM MESSAGES - CONDITION"
echo "==============================="
echo "- Write 3 messages to an entity stream"
echo "- Retrieve a batch of 2 messages from the stream, starting at position 0 where the global position is greater than or equal to 1"
echo

source test/controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

write-message $stream_name 3

cmd="SELECT * FROM get_stream_messages('$stream_name', 0, 2, condition => 'global_position >= 1');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
