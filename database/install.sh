#!/usr/bin/env bash

set -e

echo
echo "Installing Database"
echo "= = ="
echo

default_name=message_store
if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=$default_name
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"

echo

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-user {
  base=$(script_dir)
  psql -f $base/access-control/role.sql
  echo
}

function create-database {
  createdb $database
  echo
}

function create-extensions {
  base=$(script_dir)
  psql $database -f $base/extension/pgcrypto.sql
  echo
}

function create-table {
  base=$(script_dir)
  psql $database -f $base/table/messages.sql
  echo
}

base=$(script_dir)

echo
echo "Creating User: message_store"
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

# Install functions
source $base/install-functions.sh

# Install indexes
source $base/install-indexes.sh

# Install views
source $base/install-views.sh

# Install privileges
source $base/install-privileges.sh
