#!/usr/bin/env bash

echo
echo "GET CATEGORY MESSAGES"
echo "====================="
echo

test/setup.sh

psql message_store -P pager=off -c "SELECT * FROM get_category_messages('someStream', 4, 1, _condition => 'position = 3');"

echo "= = ="
echo
