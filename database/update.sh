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

base=$(script_dir)

export PGOPTIONS='-c client_min_messages=warning'

echo "Deleting Indexes"
echo "- - -"
delete-indexes
echo

# Install functions
source $base/install-functions.sh

# Install indexes
source $base/install-indexes.sh
