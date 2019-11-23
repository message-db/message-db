#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CONSUMER GROUP"
echo "======================================"
echo "- Write 10 messages to 2 entity streams in the same category but with different cardinal IDs"
echo "- Retrieve a batch of messages from the category that match the consumer group conditions"
echo

source test/controls.sh

category=$(category)
echo "Category:"
echo $category
echo


cardinal_id_1=$(id)
echo "Cardinal ID 1:"
echo $cardinal_id_1
echo

for i in {1..10}; do
  stream_name=$(compound-id-stream-name $category $cardinal_id_1)

  echo "Stream Name: $stream_name"

  write-message-correlated $stream_name
done
echo


cardinal_id_2=$(id)
echo "Cardinal ID 2:"
echo $cardinal_id_2
echo

for i in {1..10}; do
  stream_name=$(compound-id-stream-name $category $cardinal_id_2)

  echo "Stream Name: $stream_name"

  write-message-correlated $stream_name
done
echo


cmd="SELECT * FROM get_category_messages('$category');"
cmd_0="SELECT * FROM get_category_messages('$category', consumer_group_member => 0, consumer_group_size => 2);"
cmd_1="SELECT * FROM get_category_messages('$category', consumer_group_member => 1, consumer_group_size => 2);"

echo "Command:"
echo "$cmd"
echo

echo "Command 0:"
echo "$cmd_0"
echo

echo "Command 1:"
echo "$cmd_1"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"
echo
psql message_store -U message_store -P pager=off -x -c "$cmd_0"
echo
psql message_store -U message_store -P pager=off -x -c "$cmd_1"


cmd_count="SELECT COUNT(*) AS total FROM get_category_messages('$category');"
cmd_count_0="SELECT COUNT(*) AS modulo_0 FROM get_category_messages('$category', consumer_group_member => 0, consumer_group_size => 2);"
cmd_count_1="SELECT COUNT(*) AS modulo_1 FROM get_category_messages('$category', consumer_group_member => 1, consumer_group_size => 2);"

echo "Command Count:"
echo "$cmd_count"
echo

echo "Command Count 0:"
echo "$cmd_count_0"
echo

echo "Command Count 1:"
echo "$cmd_count_1"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd_count"
echo
psql message_store -U message_store -P pager=off -x -c "$cmd_count_0"
echo
psql message_store -U message_store -P pager=off -x -c "$cmd_count_1"

echo "= = ="
echo
