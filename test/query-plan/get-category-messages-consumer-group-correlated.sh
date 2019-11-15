#!/usr/bin/env bash

set -e

echo
echo "QUERY PLAN - GET CATEGORY MESSAGES - CONSUMER GROUP - CORRELATED"
echo "================================================================"
echo "- Write 2 messages each to 5 entity streams in the same category"
echo "- Retrieve a batch of 2 messages from the category, starting at global position 0 and matching the correlation category"
echo

source test/controls.sh

category=$(category)
echo "Category:"
echo $category
echo

correlation=$(category)
correlation_stream_name=$(stream-name $correlation)
echo "Correlation:"
echo $correlation
echo

for i in {1..1000}; do
  stream_name=$(stream-name $category)

  echo "Stream Name: $stream_name"

  write-message-correlated $stream_name 1
  write-message-correlated $stream_name 1 $correlation_stream_name
done
echo

cmd="
  LOAD 'auto_explain';
  SET auto_explain.log_min_duration = 0;
  SET auto_explain.log_nested_statements=on;
  EXPLAIN ANALYZE SELECT * FROM get_category_messages('$category', correlation => '$correlation', consumer_group_member => 0, consumer_group_size => 2);
"

echo "Command:"
echo "$cmd"
echo

psql message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
