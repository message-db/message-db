#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES CORRELATED"
echo "====================="
echo "- Write 2 messages each to 3 entity streams in the same category"
echo "- Retrieve a batch of 2 messages from the category, starting at global position 0 and matching the correlation stream name"
echo

source test/controls.sh

category=$(category)
echo "Category:"
echo $category
echo

correlation=$(stream-name)
echo "Correlation:"
echo $correlation
echo

for i in {1..3}; do
  stream_name=$(stream-name $category)

  echo "Stream Name: $stream_name"

  write-message-correlated $stream_name 1
  write-message-correlated $stream_name 1 $correlation
done

metadata_condition="'(metadata->>''correlationStreamName'' like ''$correlation%'')'"

echo "Metadata Condition:"
echo $metadata_condition
echo

cmd="SELECT * FROM get_category_messages('$category', 0, 2, condition => $metadata_condition);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
