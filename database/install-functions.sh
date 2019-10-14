#!/usr/bin/env bash

set -e

default_name=message_store

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=$default_name
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-types {
  base=$(script_dir)

  echo "message type"
  psql $database -f $base/types/message.sql

  echo
}

function create-functions {
  base=$(script_dir)

  echo "message_store_version function"
  psql $database -f $base/functions/message-store-version.sql

  echo "hash_64 function"
  psql $database -f $base/functions/hash-64.sql

  echo "category function"
  psql $database -f $base/functions/category.sql

  echo "stream_version function"
  psql $database -f $base/functions/stream-version.sql

  echo "write_message function"
  psql $database -f $base/functions/write-message.sql

  echo "get_stream_messages function"
  psql $database -f $base/functions/get-stream-messages.sql

  echo "get_category_messages function"
  psql $database -f $base/functions/get-category-messages.sql

  echo "get_last_message function"
  psql $database -f $base/functions/get-last-message.sql

  echo
}

echo
echo "Creating Types"
echo "- - -"
create-types

echo
echo "Creating Functions"
echo "- - -"
create-functions
