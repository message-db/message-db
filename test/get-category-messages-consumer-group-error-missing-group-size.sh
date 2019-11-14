#!/usr/bin/env bash

set -e

echo
echo "GET CATEGORY MESSAGES - CONSUMER GROUP - ERROR - MISSING GROUP SIZE"
echo "==================================================================="
echo "- Retrieve a batch of messages from the category, omitting the group size argument"
echo "- Terminates with an error"
echo

source test/controls.sh

category=$(category)
echo "Category:"
echo $category
echo

cmd="SELECT * FROM get_category_messages('someCategory', consumer_group_size => 1);"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
