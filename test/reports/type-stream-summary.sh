#!/usr/bin/env bash

set -e

echo
echo "PRINT TYPE STREAM SUMMARY"
echo "========================="
echo "- Write 3 messages to 3 entity streams"
echo "- Print the type stream summary"
echo

source test/_controls.sh

write-message
write-message
write-message

database/print-type-stream-summary.sh

echo "= = ="
echo
