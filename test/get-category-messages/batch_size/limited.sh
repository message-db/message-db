#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - BATCH SIZE - LIMTED"
echo "==========================================="
echo "- Write 2 messages each to 3 entity streams in the same category"
echo "- Retrieve a batch of 2 messages from the category"
echo

source test/_controls.sh

category=$(category)

echo "Category:"
echo $category
echo

for i in {1..3}; do
  stream_name=$(stream-name $category)
  echo $stream_name
  write-message $stream_name 2
done
echo

cmd="SELECT * FROM get_category_messages('$category', batch_size => 2);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
