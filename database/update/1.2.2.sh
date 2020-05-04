#!/usr/bin/env bash

set -e

echo
echo "Message DB"
echo
echo "Update the message_store database to v1.2.2"
echo
echo "WARNING:"
echo "This script updates a post-v1 message_store database to Message DB v1.2.2"
echo "Do not run this script on a Message DB pre-v1 database"
echo
echo "Fore more information about the changes made to the message store by"
echo "this update, see: https://github.com/message-db/message-db/blob/master/database/update/1.2.2.md"
echo
echo "- Press CTRL+C to stop this script from running"
echo "- Press RETURN to allow the script to proceed"
echo

read

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

base="$(script_dir)/.."
echo $base

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

function install-functions {
  echo "» get_stream_messages function"
  psql $database -q -f $base/functions/get-stream-messages.sql

  echo "» get_category_messages function"
  psql $database -q -f $base/functions/get-category-messages.sql
}

echo "Installing Functions"
echo "- - -"
install-functions
echo

echo "= = ="
echo "Done Updating Database"
echo "Version: $(cat $base/VERSION.txt)"
echo
