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

function create-views {
  base=$(script_dir)

  echo "» stream_summary view"
  run_psql_file $base/views/stream-summary.sql

  echo "» type_summary view"
  run_psql_file $base/views/type-summary.sql

  echo "» stream_type_summary view"
  run_psql_file $base/views/stream-type-summary.sql

  echo "» type_stream_summary view"
  run_psql_file $base/views/type-stream-summary.sql

  echo "» category_type_summary view"
  run_psql_file $base/views/category-type-summary.sql

  echo "» type_category_summary view"
  run_psql_file $base/views/type-category-summary.sql
}

echo "Creating Views"
echo "- - -"
create-views
echo
