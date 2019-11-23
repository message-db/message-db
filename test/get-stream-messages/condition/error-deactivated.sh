#!/usr/bin/env bash

set -e

echo
echo "ERROR - GET STREAM MESSAGES - CONDITION - FEATURE DEACTIVATED"
echo "============================================================="
echo "- Retrieve a batch of messages from the stream using the SQL condition when the SQL condition feature is deactivated"
echo "- Terminates with an error"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

cmd="SELECT * FROM get_stream_messages('$stream_name', condition => 'position >= 1');"

echo "Command:"
echo "$cmd"
echo

set +e
PGOPTIONS='-c message_store.sql_condition=off' psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
