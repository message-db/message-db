#!/usr/bin/env bash

echo
echo "GET LAST MESSAGE"
echo "================"
echo

source test/stream-name.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

STREAM_NAME=$stream_name INSTANCES=3 database/write-test-message.sh > /dev/null

cmd="SELECT * FROM get_last_message('$stream_name');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
