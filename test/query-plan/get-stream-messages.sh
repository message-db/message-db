#!/usr/bin/env bash

set -e

echo
echo "QUERY PLAN - GET STREAM MESSAGES"
echo "================================"
echo "- Write 3 messages to an entity stream"
echo "- Retrieve a batch of 2 messages from the stream"
echo

source test/controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

write-message $stream_name 3

cmd="
  LOAD 'auto_explain';
  SET auto_explain.log_min_duration = 0;
  SET auto_explain.log_nested_statements=on;
  EXPLAIN ANALYZE SELECT * FROM get_stream_messages('$stream_name');
"

echo "Command:"
echo "$cmd"
echo

psql message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
