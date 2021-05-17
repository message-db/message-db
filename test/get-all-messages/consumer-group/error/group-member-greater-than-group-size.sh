#!/usr/bin/env bash

set -e

echo
echo "GET ALL MESSAGES - CONSUMER GROUP - ERROR - GROUP MEMBER GREATER THAN GROUP SIZE"
echo "====================================================================================="
echo "- Retrieve a batch of messages with a consumer group member equals the group size"
echo "- Terminates with an error"
echo

source test/_controls.sh

cmd="SELECT * FROM get_all_messages(consumer_group_member => 2, consumer_group_size => 1);"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
