#!/usr/bin/env bash

set -e

echo
echo "GET ALL MESSAGES - CONDITION CORRELATED"
echo "============================================"
echo "- Write 2 messages each to 3 different categories some with a correlation category"
echo "- Retrieve a batch of 3 messages, starting at global position 0, where the position is greater than or equal to 1, and matching the correlation category"
echo

source test/_controls.sh

correlation=$(category)
correlation_stream_name=$(stream-name $correlation)
echo "Correlation:"
echo $correlation
echo

for i in {1..3}; do
  stream_name=$(stream-name $(category))

  echo "Stream Name: $stream_name"

  write-message-correlated $stream_name 1
  write-message-correlated $stream_name 1 $correlation_stream_name
done
echo

cmd="SELECT * FROM get_all_messages(0, 3, correlation => '$correlation', condition => 'position >= 1');"

echo "Command:"
echo "$cmd"
echo

PGOPTIONS='-c message_store.sql_condition=on' psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
