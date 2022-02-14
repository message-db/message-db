#!/usr/bin/env bash

set -e

echo
echo "GET LAST STREAM MESSAGE - TYPE"
echo "====================================="
echo "- Write 2 messages to an entity stream of type"
echo "- Write 1 messages to an entity stream of another type"
echo "- Retrieve the last message in the stream of the first type"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

type=$(type)
echo "Type:"
echo $type
echo

other_type="SomeOtherType"
echo "Other Type:"
echo $other_type
echo

STREAM_NAME=$stream_name TYPE=$type INSTANCES=2 database/write-test-message.sh > /dev/null
STREAM_NAME=$stream_name TYPE=$other_type INSTANCES=1 database/write-test-message.sh > /dev/null

cmd="SELECT * FROM get_last_stream_message('$stream_name', '$type');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
