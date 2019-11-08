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

  echo "» messages_id_uniq_idx index"
  psql $database -q -f $base/indexes/messages-id-uniq.sql

  echo "» messages_category_global_position_correlation_idx index"
  psql $database -q -f $base/indexes/messages-category-global-position-correlation.sql

  echo "» messages_stream_name_position_correlation_uniq_idx index"
  psql $database -q -f $base/indexes/messages-stream-name-position-correlation-uniq.sql
}

echo "Creating Indexes"
echo "- - -"
create-indexes
echo
