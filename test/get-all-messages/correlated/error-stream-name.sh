#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CORRELATED STREAM NAME ERROR"
echo "===================================================="
echo "- Retrieve a messages using a stream name as the correlation value"
echo "- Terminates with an error"
echo

source test/_controls.sh

category=$(category)
echo "Category:"
echo $category
echo

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

cmd="SELECT * FROM get_category_messages('$category', correlation => '$stream_name');"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
