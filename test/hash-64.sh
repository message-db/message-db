#!/usr/bin/env bash

set -e

echo
echo "GET HASH 64"
echo "==========="
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

psql message_store -U message_store -x -c "SELECT hash_64('$stream_name');"

echo "= = ="
echo
