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

function create-indexes {
  base=$(script_dir)

  echo "messages_id_uniq_idx"
  psql $database -f $base/indexes/messages-id-uniq.sql

  echo "messages_category_global_position_idx"
  psql $database -f $base/indexes/messages-category-global-position.sql

  echo "messages_stream_name_position_uniq_idx"
  psql $database -f $base/indexes/messages-stream-name-position-uniq.sql

  echo "messages_metadata_correlation_idx"
  psql $database -f $base/indexes/messages-metadata-correlation.sql

  echo
}

echo
echo "Creating Indexes"
echo "- - -"
create-indexes
