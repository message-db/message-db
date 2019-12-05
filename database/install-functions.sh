#!/usr/bin/env bash

set -e

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-types {
  if [ -z ${DATABASE_NAME+x} ]; then
    database=message_store
    echo "(DATABASE_NAME is not set. Using: $database.)"
  else
    database=$DATABASE_NAME
  fi

  base=$(script_dir)

  echo "» message type"
  psql $database -q -f $base/types/message.sql
}

function create-functions {
  if [ -z ${DATABASE_NAME+x} ]; then
    database=message_store
    echo "(DATABASE_NAME is not set. Using: $database.)"
  else
    database=$DATABASE_NAME
  fi

  base=$(script_dir)

  echo "» message_store_version function"
  psql $database -q -f $base/functions/message-store-version.sql

  echo "» hash_64 function"
  psql $database -q -f $base/functions/hash-64.sql

  echo "» category function"
  psql $database -q -f $base/functions/category.sql

  echo "» is_category function"
  psql $database -q -f $base/functions/is-category.sql

  echo "» id function"
  psql $database -q -f $base/functions/id.sql

  echo "» cardinal_id function"
  psql $database -q -f $base/functions/cardinal-id.sql

  echo "» stream_version function"
  psql $database -q -f $base/functions/stream-version.sql

  echo "» write_message function"
  psql $database -q -f $base/functions/write-message.sql

  echo "» get_stream_messages function"
  psql $database -q -f $base/functions/get-stream-messages.sql

  echo "» get_category_messages function"
  psql $database -q -f $base/functions/get-category-messages.sql

  echo "» get_last_stream_message function"
  psql $database -q -f $base/functions/get-last-stream-message.sql
}

echo "Creating Types"
echo "- - -"
create-types
echo

echo "Creating Functions"
echo "- - -"
create-functions
echo
