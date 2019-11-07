#!/usr/bin/env bash

set -e

echo
echo "Uninstalling Database"
echo "= = ="
echo

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=message_store
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"
echo

function delete-user {
  psql -P pager=off -c "DROP ROLE IF EXISTS message_store;"
  echo
}

function delete-database {
  psql -P pager=off -c "DROP DATABASE IF EXISTS $database;"
  echo
}

echo
echo "Deleting database \"$database\"..."
echo "- - -"
delete-database

echo
echo "Deleting database user \"$user\"..."
echo "- - -"
delete-user
