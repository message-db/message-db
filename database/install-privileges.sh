#!/usr/bin/env bash

set -e

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

function grant-privileges {
  if [ -z ${DATABASE_NAME+x} ]; then
    database=message_store
    echo "(DATABASE_NAME is not set. Using: $database.)"
  else
    database=$DATABASE_NAME
  fi

  base=$(script_dir)

  echo "» messages table privileges"
  psql $database -q -f $base/privileges/table.sql

  echo "» messages_global_position_seq sequence privileges"
  psql $database -q -f $base/privileges/sequence.sql

  echo "» functions privileges"
  psql $database -q -f $base/privileges/functions.sql

  echo "» views privileges"
  psql $database -q -f $base/privileges/views.sql
}

echo
echo "Granting Privileges"
echo "- - -"
grant-privileges
