#!/usr/bin/env bash

set -e

echo
echo "GET STREAM MESSAGES - CORRELATED STREAM NAME ERROR"
echo "=================================================="
echo "- Retrieve a messages using a stream name as the correlation value"
echo "- Terminates with an error"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

cmd="SELECT * FROM get_stream_messages('$stream_name', correlation => '$stream_name');"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
