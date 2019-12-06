#!/usr/bin/env bash

set -e

echo
echo "ANALYZE QUERY PLAN - GET STREAM MESSAGES CORRELATED"
echo "==================================================="
echo "- Write 3 messages to an entity stream"
echo "- Retrieve a batch of 2 messages from the stream matching the correlation category"
echo

source test/_controls.sh

correlation=$(category)
correlation_stream_name=$(stream-name $correlation)
echo "Correlation:"
echo $correlation
echo

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

write-message-correlated $stream_name 1
write-message-correlated $stream_name 2 $correlation_stream_name

cmd="
  LOAD 'auto_explain';
  SET auto_explain.log_min_duration = 0;
  SET auto_explain.log_nested_statements=on;
  EXPLAIN ANALYZE SELECT * FROM get_stream_messages('$stream_name', correlation => '$correlation');
"

echo "Command:"
echo "$cmd"
echo

psql message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
