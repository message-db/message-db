#!/usr/bin/env bash

set -e

echo
echo "Message DB"
echo
echo "Update the message_store database to v1.3.0"
echo
echo "Fore more information about the changes made to the message store by"
echo "this update, see: https://github.com/message-db/message-db/blob/master/database/update/1.3.0.md"
echo
echo "- Press CTRL+C to cancel"
echo "- Press RETURN to proceed"
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
echo "Updating Database"
echo "Version: 1.3.0"
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
  echo "» get_last_message function"
  run_psql "DROP FUNCTION IF EXISTS message_store.get_last_stream_message(varchar) CASCADE";

  echo "» message_store_version function"
  run_psql "DROP FUNCTION IF EXISTS message_store.message_store_version CASCADE";
}

function install-functions {
  echo "» get_last_stream_message function"
  run_psql_file $base/functions/get-last-stream-message.sql

  echo "» message_store_version function"
  run_psql_file $base/functions/message-store-version.sql
}

function grant-privileges {
  echo "» get_last_stream_message function privilege"
  run_psql "GRANT EXECUTE ON FUNCTION message_store.get_last_stream_message(varchar, varchar) TO message_store;"

  echo "» message_store_version function"
  run_psql "GRANT EXECUTE ON FUNCTION message_store.message_store_version TO message_store;"
}

echo "Deleting Functions"
echo "- - -"
delete-functions
echo

echo "Installing Functions"
echo "- - -"
install-functions
echo

echo "Granting Privileges to the Function"
echo "- - -"
grant-privileges
echo

echo "= = ="
echo "Done Updating Database"
echo "Version: 1.3.0"
echo
