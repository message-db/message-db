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

if [ -z ${STREAM_NAME+x} ]; then
  echo "(STREAM_NAME is not set)"
  stream_name=''
else
  stream_name=$STREAM_NAME
  echo "Stream name is: $STREAM_NAME"
fi

function run_psql_command {
  psql $database -v ON_ERROR_STOP=1 -U $user -P pager=off -c "$1"
}

echo
echo "Stream Type Summary"
echo "= = ="
echo

if [ -z $stream_name ]; then
  run_psql_command "SELECT * FROM stream_type_summary ORDER BY stream_name, message_count DESC, type;"
  run_psql_command "SELECT COUNT(*) AS total_count FROM messages;"
else
  run_psql_command "SELECT * FROM stream_type_summary WHERE stream_name LIKE '%$stream_name%' ORDER BY stream_name, message_count DESC;"
  run_psql_command "SELECT COUNT(*) AS total_count FROM messages WHERE stream_name LIKE '%$stream_name%';"
fi
