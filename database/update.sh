#!/usr/bin/env bash

set -e

echo
echo "Updating Database"
echo "= = ="

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=message_store
  export DATABASE_NAME=$database
else
  database=$DATABASE_NAME
fi
echo

if [ -z ${PGOPTIONS+x} ]; then
  export PGOPTIONS='-c client_min_messages=warning'
fi

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function delete-indexes {
  echo "» messages_stream_name_position_uniq_idx index"
  psql $database -q -c "DROP INDEX CONCURRENTLY IF EXISTS messages_stream_name_position_uniq_idx";

  echo "» messages_category_global_position_idx index"
  psql $database -q -c "DROP INDEX CONCURRENTLY IF EXISTS messages_category_global_position_idx";
}

function create-indexes {
  base=$(script_dir)

  echo "» messages_stream_name_position_correlation_uniq_idx index"
  psql $database -q -f $base/indexes/messages-stream-name-position-correlation-uniq.sql

  echo "» messages_category_global_position_correlation_stream_name_hash_idx index"
  psql $database -q -f $base/indexes/messages_category_global_position_correlation_idx.sql
}

base=$(script_dir)

# Install functions
source $base/install-functions.sh

echo "Deleting Indexes"
echo "- - -"
delete-indexes
echo

echo "Creating Indexes"
echo "- - -"
create-indexes
echo
