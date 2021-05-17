#!/usr/bin/env bash

set -e

echo
echo "GET ALL MESSAGES - CONSUMER GROUP - ERROR - MISSING GROUP SIZE"
echo "==================================================================="
echo "- Retrieve a batch of messages, omitting the consumer group size argument"
echo "- Terminates with an error"
echo

source test/_controls.sh

cmd="SELECT * FROM get_all_messages(consumer_group_size => 1);"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
