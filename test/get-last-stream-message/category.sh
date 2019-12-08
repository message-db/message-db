#!/usr/bin/env bash

set -e

echo
echo "GET LAST STREAM MESSAGE - CATEGORY"
echo "=================================="
echo "- Write 2 messages to a category stream"
echo "- Retrieve the last message in the stream"
echo

source test/_controls.sh

category=$(category)

echo "Category:"
echo $category
echo

STREAM_NAME=$category INSTANCES=2 database/write-test-message.sh > /dev/null

cmd="SELECT * FROM get_last_stream_message('$category');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
