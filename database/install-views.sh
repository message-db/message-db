#!/usr/bin/env bash

set -e

default_name=message_store

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=$default_name
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-views {
  base=$(script_dir)

  echo "stream_summary view"
  psql $database -f $base/views/stream-summary.sql

  echo "type_summary view"
  psql $database -f $base/views/type-summary.sql

  echo "type_stream_summary view"
  psql $database -f $base/views/stream-type-summary.sql

  echo "type_stream_summary view"
  psql $database -f $base/views/type-stream-summary.sql

  echo "category_type_summary view"
  psql $database -f $base/views/category-type-summary.sql

  echo
}

echo
echo "Creating Views"
echo "- - -"
create-views
