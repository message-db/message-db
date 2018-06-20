#!/usr/bin/env bash

echo
echo "WRITE MESSAGE"
echo "============="
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

test/recreate_database.sh

uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')

stream_name="testStream-$uuid"

STREAM_NAME=$stream_name database/write-test-message.sh

echo "= = ="
echo
