#!/usr/bin/env bash

set -e

echo
echo "STREAM VERSION"
echo "=============="
echo "- Retrieve stream version using a category instead of a stream name"
echo "- Terminates with an error"
echo

source test/_controls.sh

category=$(category)

cmd="SELECT * FROM stream_version('$category');"

echo "Command:"
echo "$cmd"
echo

set +e
psql message_store -U message_store -P pager=off -x -c "$cmd"
set -e

echo "= = ="
echo
