#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES"
echo "====================="
echo "- Write 2 messages each to 3 entity streams in the same category"
echo "- Retrieve a batch of messages (this batch will likely contain many more messages than were written by this test)"
echo

source test/_controls.sh

for i in {1..3}; do
  stream_name=$(stream-name $(category))
  echo $stream_name
  write-message $stream_name 2
done
echo

cmd="SELECT * FROM get_all_messages();"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
