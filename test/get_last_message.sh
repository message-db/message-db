#!/usr/bin/env bash

echo
echo "GET LAST MESSAGE"
echo "================"
echo

test/setup.sh

psql message_store -P pager=off -c "SELECT * FROM get_last_message('someStream-123');"

echo "= = ="
echo
