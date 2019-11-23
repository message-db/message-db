#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CONSUMER GROUP - ERROR - GROUP SIZE TOO SMALL"
echo "====================================================================="
echo "- Retrieve a batch of messages from the category with a consumer group size that is too small"
echo "- Terminates with an error"
echo

source test/_controls.sh

cmd="SELECT * FROM get_category_messages('someCategory', consumer_group_member => 0, consumer_group_size => 0);"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
