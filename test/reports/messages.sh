#!/usr/bin/env bash

set -e

echo
echo "PRINT MESSAGES"
echo "=============="
echo "- Write 3 messages to an entity stream"
echo "- Print the messages in the stream"
echo

source test/_controls.sh

stream_name=$(stream-name)

echo "Stream Name:"
echo $stream_name

write-message $stream_name 3

STREAM_NAME=$stream_name database/print-messages.sh

echo "= = ="
echo
