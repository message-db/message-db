#!/usr/bin/env bash

set -e

echo
echo "WARNING: OBSOLETE"
echo
echo "The ${BASH_SOURCE[0]} has been deprecated"
echo "See the database/update directory for current update scripts"
echo

current_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
update_directory="$current_directory/update"

echo "Contents of $update_directory"
ls -1 $update_directory

echo
