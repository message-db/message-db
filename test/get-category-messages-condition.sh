#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CONDITION"
echo "================================="
echo "- Write 2 messages each to 3 entity streams in the same category"
echo "- Retrieve a batch of 2 messages from the category, starting at global position 0 where the position is greater than or equal to 1"
echo

source test/controls.sh

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

cmd="SELECT * FROM get_category_messages('$category', 0, 2, condition => 'position >= 1');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
