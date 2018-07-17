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

echo
echo "Type Summary"
echo "= = ="
echo

if [ -z $stream_name ]; then
  psql $database -U $user -P pager=off -c "SELECT DISTINCT type, count(type) FROM messages GROUP BY type ORDER BY count DESC;"
  psql $database -U $user -P pager=off -c "SELECT count(*) FROM messages;"
else
  psql $database -U $user -P pager=off -c "SELECT DISTINCT type, count(type) FROM messages WHERE stream_name LIKE '%$stream_name%' GROUP BY type ORDER BY count DESC;"
  psql $database -U $user -P pager=off -c "SELECT count(*) FROM messages WHERE stream_name LIKE '%$stream_name%';"
fi
