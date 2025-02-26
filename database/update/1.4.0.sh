#!/usr/bin/env bash
set -e

echo
echo "Message DB"
echo
echo "Update the message_store database functions"
echo
echo "This update implements performance optimizations for get_category_messages"
echo "by providing specialized code paths for common query patterns."
echo
echo "- Press CTRL+C to cancel"
echo "- Press RETURN to proceed with the update"
echo
read

function run_psql {
  psql $database -q -v ON_ERROR_STOP=1 -c "$@"
}

function run_psql_file {
  psql $database -q -v ON_ERROR_STOP=1 -f "$1"
}

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

base="$(script_dir)/.."
echo $base
echo
echo "Updating Database Functions"
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

function delete-functions {
  echo "» get_category_messages function"
  run_psql "DROP FUNCTION IF EXISTS message_store.get_category_messages(varchar, bigint, bigint, varchar, bigint, bigint, varchar) CASCADE";
}

function install-functions {
  echo "» get_category_messages_dynamic function"
  run_psql_file $base/functions/get-category-messages-dynamic.sql
  
  echo "» get_category_messages function"
  run_psql_file $base/functions/get-category-messages.sql
}

function create-indexes {
  echo "» messages_category_position index"
  run_psql "DROP INDEX IF EXISTS message_store.messages_category_position;"
  run_psql "CREATE INDEX messages_category_position ON message_store.messages (
    message_store.category(stream_name),
    global_position
  );"
  
  echo "» messages_correlation index"
  run_psql "DROP INDEX IF EXISTS message_store.messages_correlation;"
  run_psql "CREATE INDEX messages_correlation ON message_store.messages (
    message_store.category(metadata->>'correlationStreamName')
  );"
  
  echo "» messages_consumer_group index"
  run_psql "DROP INDEX IF EXISTS message_store.messages_consumer_group;"
  run_psql "CREATE INDEX messages_consumer_group ON message_store.messages (
    message_store.cardinal_id(stream_name)
  );"
}

function grant-privileges {
  echo "» get_category_messages function privilege"
  run_psql "GRANT EXECUTE ON FUNCTION message_store.get_category_messages(varchar, bigint, bigint, varchar, bigint, bigint, varchar) TO message_store;"
  
  echo "» get_category_messages_dynamic function privilege"
  run_psql "GRANT EXECUTE ON FUNCTION message_store.get_category_messages_dynamic(varchar, bigint, bigint, varchar, bigint, bigint, varchar) TO message_store;"
}

echo "Deleting Functions"
echo "- - -"
delete-functions
echo

echo "Installing Functions"
echo "- - -"
install-functions
echo

echo "Creating Indexes"
echo "- - -"
create-indexes
echo

echo "Granting Privileges to the Functions"
echo "- - -"
grant-privileges
echo

echo "= = ="
echo "Done Updating Database"
echo "Version: 1.4.0"
echo
