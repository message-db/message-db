#!/usr/bin/env bash

set -e

echo
echo "ERROR - GET ALL MESSAGES - CONDITION - FEATURE NOT ACTIVATED"
echo "================================================================="
echo "- Retrieve a batch of messages from the category using the SQL condition when the SQL condition feature is deactivated"
echo "- Terminates with an error"
echo

source test/_controls.sh

cmd="SELECT * FROM get_all_messages(condition => 'position >= 1');"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
