#!/usr/bin/env bash

set -e

echo
echo "Installing Database"
echo "= = ="
echo

default_name=message_store

if [ -z ${DATABASE_USER+x} ]; then
  echo "(DATABASE_USER is not set. Default will be used.)"
  user=$default_name
else
  user=$DATABASE_USER
fi

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=$default_name
else
  database=$DATABASE_NAME
fi

echo

function create-user {
  echo "Database user is: $user"
  createuser -s $user
  echo
}

function create-database {
  echo "Database name is: $database"
  echo "Creating database \"$database\"..."
  createdb $database
  echo
}

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-extensions {
  echo "Creating extensions..."
  base=$(script_dir)
  psql $database -f $base/extensions.sql
  echo
}

function create-table {
  echo "Creating messages table..."
  psql $database -f $base/table/messages-table.sql
  echo
}

function create-types {
  base=$(script_dir)
  echo "Creating types..."

  echo "message type"
  psql $database -f $base/types/message.sql

  echo
}

function create-functions {
  echo "Creating functions..."
  base=$(script_dir)

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

function create-indexes {
  echo "Creating indexes..."
  base=$(script_dir)

  echo "messages_id_idx"
  psql $database -f $base/indexes/messages-id.sql

  echo "messages_category_global_position_idx"
  psql $database -f $base/indexes/messages-category-global-position.sql

  echo "messages_stream_name_position_uniq_idx"
  psql $database -f $base/indexes/messages-stream-name-position-uniq.sql

  echo
}

create-user
create-database
create-extensions
create-table
create-types
create-functions
create-indexes
