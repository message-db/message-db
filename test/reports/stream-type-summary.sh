#!/usr/bin/env bash

set -e

echo
echo "PRINT STREAM TYPE SUMMARY"
echo "========================="
echo "- Write 3 messages to an entity streams"
echo "- Write a messages to 2 other entity streams"
echo "- Print the stream type summary"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name

write-message $stream_name 3
write-message
write-message

STREAM_NAME=$stream_name database/print-stream-type-summary.sh

echo "= = ="
echo
