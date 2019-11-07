#!/usr/bin/env bash

set -e

echo
echo "Updating Database"
echo "= = ="
echo

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=message_store
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"

echo

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

base=$(script_dir)

# Install functions
source $base/install-functions.sh

# Install indexes

# DROP INDEX CONCURRENTLY IF EXISTS "messages_category_global_position_idx";
# DROP INDEX CONCURRENTLY IF EXISTS "messages_stream_name_position_uniq_idx";


source $base/install-indexes.sh

# Install views
source $base/install-views.sh

# Install privileges
source $base/install-privileges.sh
