#!/usr/bin/env bash

set -e

echo
echo "CATEGORY - FROM CATEGORY"
echo "========================"
echo

source test/controls.sh

category=$(category)

echo "Category:"
echo $category
echo

psql message_store -U message_store -x -c "SELECT category('$category');"

echo "= = ="
echo
