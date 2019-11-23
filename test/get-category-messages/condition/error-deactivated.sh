#!/usr/bin/env bash

set -e

echo
echo "ERROR - GET CATEGORY MESSAGES - CONDITION - FEATURE DEACTIVATED"
echo "==============================================================="
echo "- Retrieve a batch of messages from the category using the SQL condition when the SQL condition feature is deactivated"
echo "- Terminates with an error"
echo

source test/_controls.sh

category=$(category)

echo "Category:"
echo $category
echo

cmd="SELECT * FROM get_category_messages('$category', condition => 'position >= 1');"

echo "Command:"
echo "$cmd"
echo

set +e
PGOPTIONS='-c message_store.sql_condition=off' psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
