#!/usr/bin/env bash

echo
echo "WRITE MESSAGE"
echo "============="
echo "Write a single message to an entity stream"
echo

source test/controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

write-message $stream_name

psql message_store -U message_store -P pager=off -x -c "SELECT * FROM messages WHERE stream_name = '$stream_name';"

echo "= = ="
echo
