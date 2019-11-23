#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CONSUMER GROUP - CORRELATED"
echo "==================================================="
echo "- Write 2 messages each to 10 entity streams in the same category"
echo "- Half of the messages have a different cardinal ID that the other half"
echo "- Retrieve messages from the category that match the consumer group conditions"
echo

source test/_controls.sh

category=$(category)
echo "Category:"
echo $category
echo

correlation=$(category)
correlation_stream_name=$(stream-name $correlation)
echo "Correlation:"
echo $correlation
echo


cardinal_id_1=$(id)
echo "Cardinal ID 1:"
echo $cardinal_id_1
echo

for i in {1..5}; do
  stream_name=$(compound-id-stream-name $category $cardinal_id_1)

  echo "Stream Name: $stream_name"

  write-message-correlated $stream_name 1
  write-message-correlated $stream_name 1 $correlation_stream_name
done
echo


cardinal_id_2=$(id)
echo "Cardinal ID 2:"
echo $cardinal_id_2
echo

for i in {1..5}; do
  stream_name=$(compound-id-stream-name $category $cardinal_id_2)

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


echo "Correlated messages written to the category for consumer member 0"
echo

cmd="SELECT * FROM get_category_messages('$category', 0, 10, correlation => '$correlation', consumer_group_member => 0, consumer_group_size => 2);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"


echo "A batch of 1 message written to the category for consumer member 0 greater than global position 2"
echo

cmd="SELECT * FROM get_category_messages('$category', 2, 1, correlation => '$correlation', consumer_group_member => 0, consumer_group_size => 2);"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
