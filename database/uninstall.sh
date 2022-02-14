#!/usr/bin/env bash

set -e

function run_psql_command {
  psql -q -v ON_ERROR_STOP=1 -P pager=off postgres -c "$1"
}

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

base=$(script_dir)

echo
echo "Uninstalling Database"
echo "Version: $(cat $base/VERSION.txt)"
echo "= = ="

if [ -z ${DATABASE_NAME+x} ]; then
  database=message_store
  echo "DATABASE_NAME is not set. Using: $database."
else
  database=$DATABASE_NAME
fi
echo

if [ -z ${PGOPTIONS+x} ]; then
  export PGOPTIONS='-c client_min_messages=warning'
fi

function delete-user {
  echo "» message_store user"
  run_psql_command "DROP ROLE IF EXISTS message_store;"
}

function delete-database {
  echo "» $database database"
  run_psql_command "DROP DATABASE IF EXISTS \"$database\";"
}

echo "Deleting database"
echo "- - -"
delete-database
echo

echo "Deleting database user"
echo "- - -"
delete-user

echo

echo "= = ="
echo "Done Uninstalling Database"
echo "Version: $(cat $base/VERSION.txt)"
echo
