#!/usr/bin/env bash

set -e

echo
echo "Printing Messages"
echo "= = ="
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

default_table_name=messages

if [ -z ${STREAM_NAME+x} ]; then
  echo "(STREAM_NAME is not set)"
  stream_name=''
else
  stream_name=$STREAM_NAME
  echo "Stream name is: $STREAM_NAME"
fi

function run_psql_command {
  psql $database -v ON_ERROR_STOP=1 -U $user -P pager=off -x -c "$1"
}

echo

if [ -z $stream_name ]; then
  run_psql_command "SELECT * FROM messages ORDER BY global_position ASC"
else
  run_psql_command "SELECT * FROM messages WHERE stream_name = '$stream_name' ORDER BY global_position ASC"
fi
