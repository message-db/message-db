#!/usr/bin/env bash

set -e

echo
echo "GET STREAM MESSAGES - CONSUMER GROUP"
echo "===================================="
echo "- Write 3 messages to an entity stream"
echo "- Retrieve a batch of 2 messages from the stream, starting at position 0 and matching the consumer group conditions"
echo

source test/controls.sh

correlation_stream_name=$(stream-name $correlation)
echo "Correlation:"
echo $correlation
echo

category=$(category)
echo "Category:"
echo $category
echo

stream_name=$(stream-name $category)

echo "Stream Name:"
echo $stream_name
echo

write-message $stream_name 3

# “@hash_64(stream_name) % #{group_size} = #{group_member}"

cmd="SELECT * FROM get_stream_messages('$stream_name', 0, 2);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
