#!/usr/bin/env bash

set -e

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-views {
  if [ -z ${DATABASE_NAME+x} ]; then
    database=message_store
    echo "(DATABASE_NAME is not set. Using: $database.)"
  else
    database=$DATABASE_NAME
  fi

  base=$(script_dir)

  echo "» stream_summary view"
  psql $database -q -f $base/views/stream-summary.sql

  echo "» type_summary view"
  psql $database -q -f $base/views/type-summary.sql

  echo "» type_stream_summary view"
  psql $database -q -f $base/views/stream-type-summary.sql

  echo "» type_stream_summary view"
  psql $database -q -f $base/views/type-stream-summary.sql

  echo "» category_type_summary view"
  psql $database -q -f $base/views/category-type-summary.sql

  echo "» type_category_summary view"
  psql $database -q -f $base/views/type-category-summary.sql
}

echo "Creating Views"
echo "- - -"
create-views
echo
