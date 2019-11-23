#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - ERROR - NOT CATEGORY"
echo "============================================"
echo "- Retrieve a batch of messages from the category using a stream name instead of a category"
echo "- Terminates with an error"
echo

source test/_controls.sh

stream_name=$(stream-name)

cmd="SELECT * FROM get_category_messages('$stream_name');"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
