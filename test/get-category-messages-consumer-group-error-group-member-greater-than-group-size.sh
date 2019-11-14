#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CONSUMER GROUP - ERROR - GROUP MEMBER GREATER THAN GROUP SIZE"
echo "====================================================================================="
echo "- Retrieve a batch of messages from the category with a consumer group member equals the group size"
echo "- Terminates with an error"
echo

source test/controls.sh

cmd="SELECT * FROM get_category_messages('someCategory', consumer_group_member => 2, consumer_group_size => 1);"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
