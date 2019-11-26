#!/usr/bin/env bash

set -e

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

base=$(script_dir)

echo
echo "Updating Database"
echo "Version: $(cat $base/VERSION.txt)"
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

function delete-indexes {
  echo "» messages_id_uniq_idx index"
  psql $database -q -c "DROP INDEX IF EXISTS messages_id_uniq_idx CASCADE";

  echo "» messages_stream_name_position_uniq_idx index"
  psql $database -q -c "DROP INDEX IF EXISTS messages_stream_name_position_uniq_idx";

  echo "» messages_category_global_position_idx index"
  psql $database -q -c "DROP INDEX IF EXISTS messages_category_global_position_idx";
}

function delete-functions {
  echo "» get_last_message function"
  psql $database -q -c "DROP FUNCTION IF EXISTS hash_64 CASCADE";

  echo "» category function"
  psql $database -q -c "DROP FUNCTION IF EXISTS category CASCADE";

  echo "» stream_version function"
  psql $database -q -c "DROP FUNCTION IF EXISTS stream_version CASCADE";

  echo "» write_message function"
  psql $database -q -c "DROP FUNCTION IF EXISTS write_message CASCADE";

  echo "» get_last_message function"
  psql $database -q -c "DROP FUNCTION IF EXISTS get_last_message CASCADE";
}

echo "Deleting Indexes"
echo "- - -"
delete-indexes
echo

echo "Deleting Functions"
echo "- - -"
delete-functions
echo

# Install functions
source $base/install-functions.sh

# Install indexes
source $base/install-indexes.sh

# Install views
source $base/install-views.sh

# Install privileges
source $base/install-privileges.sh

echo "= = ="
echo "Done Updating Database"
echo "Version: $(cat $base/VERSION.txt)"
echo
