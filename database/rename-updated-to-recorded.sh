#!/usr/bin/env bash

set -e

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
echo "Replacing Updated Event with Recorded Event"
echo "= = ="
echo

psql $database -U $user -P pager=off -c "UPDATE messages SET type = 'Recorded' WHERE type = 'Updated' AND (stream_name LIKE '%+position' OR stream_name LIKE '%:position' OR stream_name LIKE '%:position-%');"
