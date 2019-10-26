#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES CORRELATED"
echo "====================="
echo "- Write 2 messages each to 3 entity streams in the same category"
echo "- Retrieve a batch of 2 messages from the category, starting at global position 0 where the position is greater than or equal to 1 and the correlation stream name is someCorrelation"
echo

source test/controls.sh

category=$(category)

echo "Category:"
echo $category
echo

# correlation=$(stream-name)

# echo "Correlation:"
# echo $correlation
# echo

for i in {1..2}; do
  stream_name=$(stream-name $category)
  correlation=$(stream-name)

  echo "Stream Name: $stream_name"
  echo "Correlation: $correlation"

  write-message-correlated $stream_name 1
  write-message-correlated $stream_name 1 $correlation
done


stream_name=$(stream-name $category)
correlation=$(stream-name)

echo "Stream Name: $stream_name"
echo "Correlation: $correlation"
echo

write-message-correlated $stream_name 1
write-message-correlated $stream_name 1 $correlation

metadata_condition="'(metadata->>''correlationStreamName'' like ''$correlation%'')'"
echo "Metadata Condition: $metadata_condition"

cmd="SELECT * FROM get_category_messages('$category', 0, 1000, $metadata_condition);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
