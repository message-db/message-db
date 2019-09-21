#!/usr/bin/env bash

echo
echo "GET CATEGORY MESSAGES"
echo "====================="
echo
source test/stream-name.sh

uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')
category_suffix=${uuid:0:8}
category="testStream$category_suffix"

echo "Category:"
echo $category
echo

echo "Stream Names:"
for i in {1..3}; do
  stream_name=$(stream-name $category)
  echo $stream_name
  STREAM_NAME=$stream_name INSTANCES=2 database/write-test-message.sh > /dev/null
done
echo

cmd="SELECT * FROM get_category_messages('$category', 0, 2, _condition => 'position >= 1');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
