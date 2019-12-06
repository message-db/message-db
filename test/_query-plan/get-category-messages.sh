#!/usr/bin/env bash

set -e

echo
echo "QUERY PLAN - GET CATEGORY MESSAGES"
echo "=================================="
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

cmd="
  LOAD 'auto_explain';
  SET auto_explain.log_min_duration = 0;
  SET auto_explain.log_nested_statements=on;
  EXPLAIN ANALYZE SELECT * FROM get_category_messages('$category');
"

echo "Command:"
echo "$cmd"
echo

psql message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
