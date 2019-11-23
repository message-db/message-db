#!/usr/bin/env bash

set -e

echo
echo "PRINT STREAM SUMMARY"
echo "===================="
echo "- Write 3 messages to an entity stream"
echo "- Write a messages to another entity stream"
echo "- Print the message summary for the stream"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name

write-message $stream_name 3
write-message

STREAM_NAME=$stream_name database/print-stream-summary.sh

echo "= = ="
echo
