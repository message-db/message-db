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
echo "Database user is: $user"

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=$default_name
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"

echo

function create-user {
  createuser -s $user
  echo
}

function create-database {
  createdb $database
  echo
}

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-extensions {
  base=$(script_dir)
  psql $database -f $base/extensions.sql
  echo
}

function create-table {
  psql $database -f $base/table/messages-table.sql
  echo
}

function create-types {
  base=$(script_dir)

  echo "message type"
  psql $database -f $base/types/message.sql

  echo
}

function create-indexes {
  base=$(script_dir)

  echo "messages_id_idx"
  psql $database -f $base/indexes/messages-id.sql

  echo "messages_category_global_position_idx"
  psql $database -f $base/indexes/messages-category-global-position.sql

  echo "messages_stream_name_position_uniq_idx"
  psql $database -f $base/indexes/messages-stream-name-position-uniq.sql

  echo
}

echo
echo "Creating User: $user"
echo "- - -"
create-user

echo
echo "Creating Database: $database"
echo "- - -"
create-database


echo
echo "Creating Extensions"
echo "- - -"
create-extensions


echo
echo "Creating Table"
echo "- - -"
create-table

source $base/install-functions.sh

echo
echo "Creating Indexes"
echo "- - -"
create-indexes
