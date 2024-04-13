#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - DATA MATCH"
echo "=================================="
echo "- Write 3 messages each to 3 entity streams in the same category with varying data"
## Why 0 when the default is 1? - Aaron, Fri Apr 12 2024
echo "- Retrieve a batch of 2 messages from the category, starting at global position 0 where the data matches specific jsonpath"
echo

source test/_controls.sh

category=$(category)

echo "Category:"
echo $category
echo

data="'{\"attribute\": \"some value\"}'"
other_data="'{\"attribute\": \"some other value\"}'"

for i in {1..3}; do
  stream_name=$(stream-name $category)
  echo $stream_name
  DATA="$other_data" write-message $stream_name 1
  DATA="$data" write-message $stream_name 2
done
echo

data_condition="$.attribute == \"some value\""
cmd="SELECT * FROM get_category_messages('$category', 0, 2, data_condition => '$data_condition');"

echo "Command:"
echo "$cmd"
echo

PGOPTIONS='-c message_store.sql_condition=on' psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
