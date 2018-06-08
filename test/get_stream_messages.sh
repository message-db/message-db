#!/usr/bin/env bash

echo
echo "GET STREAM MESSAGES"
echo "==================="
echo

test/setup.sh

psql message_store -P pager=off -c "select * from get_stream_messages('someStream-123', 2, 1, _condition => 'global_position = 3');"

echo "= = ="
echo
