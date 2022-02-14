#!/usr/bin/env bash

set -ue

function run_psql {
  psql -v ON_ERROR_STOP=1 "$@"
}

instances=1
if [ ! -z ${INSTANCES+x} ]; then
  instances=$INSTANCES
fi

uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')
stream_name="testStream-$uuid"
if [ ! -z ${STREAM_NAME+x} ]; then
  stream_name=$STREAM_NAME
fi

type="SomeType"
if [ ! -z ${TYPE+x} ]; then
  type=$TYPE
fi

title="Writing $instances Messages to Stream $stream_name"
if [ -z ${METADATA+x} ]; then
  metadata="'{\"metaAttribute\": \"some meta value\"}'"
else
  metadata="$METADATA"
  title="$title with Metadata $metadata"
fi

metadata="$metadata::jsonb"

echo
echo $title
echo "= = ="
echo

default_name=message_store

if [ -z ${DATABASE_USER+x} ]; then
  echo "(DATABASE_USER is not set)"
  user=$default_name
else
  user=$DATABASE_USER
fi
echo "Database user is: $user"

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set)"
  database=$default_name
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"
echo


for (( i=1; i<=instances; i++ )); do
  uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')

  echo "Instance: $i, Message ID: $uuid"

  run_psql $database -U $user -c "SELECT write_message('$uuid'::varchar, '$stream_name'::varchar, '$type'::varchar, '{\"attribute\": \"some value\"}'::jsonb, $metadata);" > /dev/null
done


echo
run_psql $database -U $user -P pager=off -x -c "SELECT * FROM messages WHERE stream_name = '$stream_name';"

echo
