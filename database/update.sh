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

function delete-extensions {
  echo "» pgcrypto extension"
  psql $database -q -c "DROP EXTENSION IF EXISTS pgcrypto";
}

function delete-indexes {
  echo "» messages_id_uniq_idx index"
  psql $database -q -c "DROP INDEX IF EXISTS messages_id_uniq_idx CASCADE";

  echo "» messages_stream_name_position_uniq_idx index"
  psql $database -q -c "DROP INDEX IF EXISTS messages_stream_name_position_uniq_idx";

  echo "» messages_category_global_position_idx index"
  psql $database -q -c "DROP INDEX IF EXISTS messages_category_global_position_idx";
}

function delete-views {
  echo "» stream_summary view"
  psql $database -q -c "DROP VIEW IF EXISTS stream_summary CASCADE";

  echo "» type_summary view"
  psql $database -q -c "DROP VIEW IF EXISTS type_summary CASCADE";

  echo "» stream_type_summary view"
  psql $database -q -c "DROP VIEW IF EXISTS stream_type_summary CASCADE";

  echo "» type_stream_summary view"
  psql $database -q -c "DROP VIEW IF EXISTS type_stream_summary CASCADE";

  echo "» category_type_summary view"
  psql $database -q -c "DROP VIEW IF EXISTS category_type_summary CASCADE";

  echo "» type_category_summary view"
  psql $database -q -c "DROP VIEW IF EXISTS type_category_summary CASCADE";
}

function delete-functions {
  echo "» hash_64 function"
  psql $database -q -c "DROP FUNCTION IF EXISTS hash_64 CASCADE";

  echo "» category function"
  psql $database -q -c "DROP FUNCTION IF EXISTS category CASCADE";

  echo "» stream_version function"
  psql $database -q -c "DROP FUNCTION IF EXISTS stream_version CASCADE";

  echo "» write_message function"
  psql $database -q -c "DROP FUNCTION IF EXISTS write_message CASCADE";

  echo "» get_stream_messages function"
  psql $database -q -c "DROP FUNCTION IF EXISTS get_stream_messages CASCADE";

  echo "» get_category_messages function"
  psql $database -q -c "DROP FUNCTION IF EXISTS get_category_messages CASCADE";

  echo "» get_last_message function"
  psql $database -q -c "DROP FUNCTION IF EXISTS get_last_message CASCADE";
}

function delete-extensions {
  echo "» pgcrypto extension"
  psql $database -q -c "DROP EXTENSION IF EXISTS pgcrypto CASCADE";
}

function create-schema {
  echo "» message_store schema"
  psql $database -q -f $base/schema/message-store.sql
}

function add-table-to-schema {
  echo "» messages table"
  psql $database -q -c "ALTER TABLE messages SET SCHEMA message_store";
}

function create-extensions {
  base=$(script_dir)

  echo "» pgcrypto extension"
  psql $database -q -f $base/extensions/pgcrypto.sql
}

function set-default-value {
  echo "» id column"
  psql $database -q -c "ALTER TABLE message_store.messages ALTER COLUMN id SET DEFAULT gen_random_uuid()";
}

echo "Deleting Views"
echo "- - -"
delete-views
echo

echo "Deleting Indexes"
echo "- - -"
delete-indexes
echo

echo "Deleting Functions"
echo "- - -"
delete-functions
echo

echo "Deleting Extensions"
echo "- - -"
delete-extensions
echo

echo "Creating Schema"
echo "- - -"
create-schema
echo

echo "Creating Extensions"
echo "- - -"
create-extensions
echo

echo "Adding Table to Schema"
echo "- - -"
add-table-to-schema
echo

echo "Set Default Value for ID Column"
echo "- - -"
set-default-value
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
