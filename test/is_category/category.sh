#!/usr/bin/env bash

set -e

echo
echo "IS CATEGORY - CATEGORY"
echo "======================"
echo

source test/_controls.sh

category=$(category)

echo "Category:"
echo $category
echo

psql message_store -U message_store -x -c "SELECT is_category('$category');"

echo "= = ="
echo
