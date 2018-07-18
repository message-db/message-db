#!/usr/bin/env bash

echo
echo "GET HASH 64"
echo "==========="
echo

default_name=message_store

if [ -z ${DATABASE_USER+x} ]; then
  echo "(DATABASE_USER is not set)"
  user=$default_name
else
  user=$DATABASE_USER
fi
echo "Database user is: $user"

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set)"
  database=$default_name
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"
echo

test/recreate-database.sh

psql $database -U $user -c "SELECT hash_64('someStream-123');"

echo "= = ="
echo
