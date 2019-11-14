#!/usr/bin/env bash

set -e

echo
echo "GET STREAM MESSAGES - ERROR - NOT STREAM NAME"
echo "============================================="
echo "- Retrieve a batch of messages from the stream using a category instead of a stream name"
echo "- Terminates with an error"
echo

source test/controls.sh

category=$(category)

cmd="SELECT * FROM get_stream_messages('$category');"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
