#!/usr/bin/env bash

set -e

echo
echo "PRINT CATEGORY TYPE SUMMARY"
echo "==========================="
echo "- Write 3 messages to 3 entity streams"
echo "- Print the category type summary"
echo

source test/_controls.sh

write-message
write-message
write-message

database/print-category-type-summary.sh

echo "= = ="
echo
