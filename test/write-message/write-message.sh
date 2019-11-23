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

STREAM_NAME=$stream_name database/write-test-message.sh > /dev/null

psql message_store -U message_store -P pager=off -x -c "SELECT * FROM messages WHERE stream_name = '$stream_name';"

echo "= = ="
echo
