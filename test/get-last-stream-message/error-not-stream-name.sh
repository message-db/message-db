#!/usr/bin/env bash

set -e

echo
echo "GET LAST MESSAGE - ERROR - NOT STREAM NAME"
echo "=========================================="
echo "- Retrieve the last message in a stream using a category instead of a stream name"
echo "- Terminates with an error"
echo

source test/_controls.sh

category=$(category)

cmd="SELECT * FROM get_last_stream_message('$category');"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
