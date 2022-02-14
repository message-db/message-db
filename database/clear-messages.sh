#!/usr/bin/env bash

set -e

echo
echo "Clearing Messages Table"
echo "= = ="
echo

default_name=message_store

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set)"
  database=$default_name
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"

echo

psql $database -v ON_ERROR_STOP=1 -q -c "TRUNCATE message_store.messages RESTART IDENTITY;"

echo "= = ="
echo "Done Clearing Messages Table"
echo
