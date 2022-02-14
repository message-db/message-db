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

function create-indexes {
  base=$(script_dir)

  echo "» messages_id index"
  run_psql_file $base/indexes/messages-id.sql

  echo "» messages_stream index"
  run_psql_file $base/indexes/messages-stream.sql

  echo "» messages_category index"
  run_psql_file $base/indexes/messages-category.sql
}

echo "Creating Indexes"
echo "- - -"
create-indexes
echo
