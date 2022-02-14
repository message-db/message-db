#!/usr/bin/env bash

set -e

if [ -z ${DATABASE_NAME+x} ]; then
  database=message_store
  echo "(DATABASE_NAME is not set. Using: $database.)"
else
  database=$DATABASE_NAME
fi

function run_psql_file {
  psql -q -v ON_ERROR_STOP=1 $database -f "$1"
}

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-types {
  base=$(script_dir)

  echo "» message type"
  run_psql_file $base/types/message.sql
}

function create-functions {
  base=$(script_dir)

  echo "» message_store_version function"
  run_psql_file $base/functions/message-store-version.sql

  echo "» hash_64 function"
  run_psql_file $base/functions/hash-64.sql

  echo "» acquire_lock function"
  run_psql_file $base/functions/acquire-lock.sql

  echo "» category function"
  run_psql_file $base/functions/category.sql

  echo "» is_category function"
  run_psql_file $base/functions/is-category.sql

  echo "» id function"
  run_psql_file $base/functions/id.sql

  echo "» cardinal_id function"
  run_psql_file $base/functions/cardinal-id.sql

  echo "» stream_version function"
  run_psql_file $base/functions/stream-version.sql

  echo "» write_message function"
  run_psql_file $base/functions/write-message.sql

  echo "» get_stream_messages function"
  run_psql_file $base/functions/get-stream-messages.sql

  echo "» get_category_messages function"
  run_psql_file $base/functions/get-category-messages.sql

  echo "» get_last_stream_message function"
  run_psql_file $base/functions/get-last-stream-message.sql
}

echo "Creating Types"
echo "- - -"
create-types
echo

echo "Creating Functions"
echo "- - -"
create-functions
echo
