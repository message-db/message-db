#!/usr/bin/env bash

set -e

if [ -z ${DATABASE_NAME+x} ]; then
  database=message_store
  echo "(DATABASE_NAME is not set. Using: $database.)"
else
  database=$DATABASE_NAME
fi

function run_psql_file {
  psql $database -q -v ON_ERROR_STOP=1 -f "$1"
}

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function grant-privileges {
  base=$(script_dir)

  echo "» schema privileges"
  run_psql_file $base/privileges/schema.sql

  echo "» messages table privileges"
  run_psql_file $base/privileges/table.sql

  echo "» sequence privileges"
  run_psql_file $base/privileges/sequence.sql

  echo "» functions privileges"
  run_psql_file $base/privileges/functions.sql

  echo "» views privileges"
  run_psql_file $base/privileges/views.sql
}

echo "Granting Privileges"
echo "- - -"
grant-privileges
echo
