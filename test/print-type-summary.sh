#!/usr/bin/env bash

set -e

echo
echo "PRINT TYPE SUMMARY"
echo "=================="
echo "- Write 3 messages to 3 entity streams"
echo "- Print the type summary"
echo

source test/controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name

write-message
write-message
write-message

database/print-type-summary.sh

echo "= = ="
echo
