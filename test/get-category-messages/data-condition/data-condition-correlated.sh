#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - DATA MATCH CORRELATED"
echo "=================================="
echo "- Write 3 messages each to 3 entity streams in the same category with varying data"
echo "- Retrieve a batch of 2 messages from the category, starting at global position 0 where the data matches specific jsonpath, and matching the correlation category"
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

data="'{\"attribute\": \"some value\"}'"
other_data="'{\"attribute\": \"some other value\"}'"

for i in {1..3}; do
  stream_name=$(stream-name $category)

  echo "Stream Name: $stream_name"

  DATA="$other_data" write-message-correlated $stream_name 1
  DATA="$other_data" write-message-correlated $stream_name 1 $correlation_stream_name
  DATA="$data" write-message-correlated $stream_name 1
  DATA="$data" write-message-correlated $stream_name 1 $correlation_stream_name
done
echo

data_condition="$.attribute == \"some value\""
cmd="SELECT * FROM get_category_messages('$category', 0, 2, correlation => '$correlation', data_condition => '$data_condition');"

echo "Command:"
echo "$cmd"
echo

PGOPTIONS='-c message_store.sql_condition=on' psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
