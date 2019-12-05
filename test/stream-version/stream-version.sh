#!/usr/bin/env bash

set -e

echo
echo "STREAM VERSION"
echo "=============="
echo "- Write 2 messages to an entity stream"
echo "- Retrieve stream version"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

write-message $stream_name 2

cmd="SELECT * FROM stream_version('$stream_name');"

echo "Command:"
echo "$cmd"
echo

psql message_store -U message_store -P pager=off -x -c "$cmd"

echo "= = ="
echo
