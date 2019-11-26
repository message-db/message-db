#!/usr/bin/env bash

set -e

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function create-indexes {
  if [ -z ${DATABASE_NAME+x} ]; then
    database=message_store
    echo "(DATABASE_NAME is not set. Using: $database.)"
  else
    database=$DATABASE_NAME
  fi

  base=$(script_dir)

  echo "» messages_id index"
  psql $database -q -f $base/indexes/messages-id.sql

  echo "» messages_stream index"
  psql $database -q -f $base/indexes/messages-stream.sql

  echo "» messages_category index"
  psql $database -q -f $base/indexes/messages-category.sql
}

echo "Creating Indexes"
echo "- - -"
create-indexes
echo
