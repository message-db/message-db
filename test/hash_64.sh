#!/usr/bin/env bash

echo
echo "GET HASH 64"
echo "==========="
echo

test/recreate_database.sh

psql message_store -c "SELECT hash_64('someStream-123');"

echo "= = ="
echo
