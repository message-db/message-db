#!/usr/bin/env bash

set -e

echo
echo "Clearing Events Table"
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

if [ -z ${TABLE_NAME+x} ]; then
  echo "(TABLE_NAME is not set)"
  table=$default_table_name
else
  table=$TABLE_NAME
fi
echo "Table name is: $table"

echo

psql $database -c "TRUNCATE $table RESTART IDENTITY;"
