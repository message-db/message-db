#!/usr/bin/env bash

echo
echo "WRITE MESSAGE EXPECTED VERSION ERROR"
echo "===================================="
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

STREAM_NAME=someStream-123 INSTANCES=4 database/write-test-message.sh

psql $database -U $user -c "SELECT write_message(gen_random_uuid()::varchar, 'someStream-123'::varchar, 'SomeType'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb, 4::bigint);"

echo "= = ="
echo
