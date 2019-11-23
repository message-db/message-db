#!/usr/bin/env bash

set -e

echo
echo "CATEGORY - FROM STREAM NAME"
echo "==========================="
echo

source test/controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name
echo

psql message_store -U message_store -x -c "SELECT category('$stream_name');"

echo "= = ="
echo
