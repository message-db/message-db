#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CONSUMER GROUP - CORRELATED"
echo "==================================================="
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

for i in {1..5}; do
  stream_name=$(stream-name $category)

  echo "Stream Name: $stream_name"

  write-message-correlated $stream_name 1
  write-message-correlated $stream_name 1 $correlation_stream_name
done
echo


echo "All messages written to the category"
echo

cmd="SELECT * FROM get_category_messages('$category');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"


echo "Correlated messages written to the category for consumer group 1"
echo

cmd="SELECT * FROM get_category_messages('$category', 0, 10, correlation => '$correlation', consumer_group_member => 0, consumer_group_size => 2);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"


echo "A batch of 1 message written to the category for consumer group 1 greater than global position 2"
echo

cmd="SELECT * FROM get_category_messages('$category', 2, 1, correlation => '$correlation', consumer_group_member => 0, consumer_group_size => 2);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
