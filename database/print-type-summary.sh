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

if [ -z ${TYPE+x} ]; then
  echo "(TYPE is not set)"
  type=''
else
  type=$TYPE
  echo "Type is: $TYPE"
fi

function run_psql_command {
  psql $database -v ON_ERROR_STOP=1 -U $user -P pager=off -c "$1"
}

echo
echo "Type Summary"
echo "= = ="
echo

if [ -z $type ]; then
  run_psql_command "SELECT * FROM type_summary ORDER BY message_count DESC;"
  run_psql_command "SELECT COUNT(*) AS total_count FROM messages;"
else
  run_psql_command "SELECT * FROM type_summary WHERE type LIKE '%$type%' ORDER BY message_count DESC;"
  run_psql_command "SELECT COUNT(*) AS total_count FROM messages WHERE type LIKE '%$type%';"
fi
