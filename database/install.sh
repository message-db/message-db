#!/usr/bin/env bash

set -e

echo
echo "Installing Database"
echo "= = ="

if [ -z ${DATABASE_NAME+x} ]; then
  database=message_store
  echo "DATABASE_NAME is not set. Using: $database."
  export DATABASE_NAME=$database
else
  database=$DATABASE_NAME
fi

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-user {
  base=$(script_dir)

  echo "» message_store role"
  psql -q -f $base/roles/message-store.sql
}

function create-database {
  echo "» $database database"
  createdb $database
}

function create-extensions {
  base=$(script_dir)

  echo "» pgcrypto extension"
  psql $database -q -f $base/extensions/pgcrypto.sql
}

function create-table {
  base=$(script_dir)

  echo "» messages table"
  psql $database -q -f $base/tables/messages.sql
}

base=$(script_dir)

export PGOPTIONS='-c client_min_messages=warning'

echo

echo "Creating User"
echo "- - -"
create-user
echo

echo "Creating Database"
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
echo

# Install functions
source $base/install-functions.sh

# Install indexes
source $base/install-indexes.sh

# Install views
source $base/install-views.sh

# Install privileges
source $base/install-privileges.sh
