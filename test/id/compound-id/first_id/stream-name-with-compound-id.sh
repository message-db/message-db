#!/usr/bin/env bash

set -e

echo
echo "GET FIRST ID FROM STREAM NAME WITH COMPOUND ID"
echo "=============================================="
echo

source test/controls.sh

stream_name=$(compound-id-stream-name)

echo "Stream Name:"
echo $stream_name
echo

psql message_store -U message_store -x -c "SELECT first_id('$stream_name');"

echo "= = ="
echo
