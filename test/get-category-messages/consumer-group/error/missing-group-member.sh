#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CONSUMER GROUP - ERROR - MISSING GROUP MEMBER"
echo "====================================================================="
echo "- Retrieve a batch of messages from the category, omitting the consumer group member argument"
echo "- Terminates with an error"
echo

source test/_controls.sh

cmd="SELECT * FROM get_category_messages('someCategory', consumer_group_member => 1);"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
