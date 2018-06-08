#!/usr/bin/env bash

set -u

instances=1
if [ ! -z ${INSTANCES+x} ]; then
  instances=$INSTANCES
fi

stream_name='someStream-123'
if [ ! -z ${STREAM_NAME+x} ]; then
  stream_name=$STREAM_NAME
fi

echo "Writing $instances messages to $stream_name"
echo "- - -"

for (( i=1; i<=instances; i++ )); do
  uuid=$(uuidgen)
  echo "Instance: $i, ID: $uuid, Stream Name: $stream_name"
  psql message_store -c "SELECT write_message('$uuid'::varchar, '$stream_name'::varchar, 'SomeType'::varchar, '{\"attribute\": \"some value\"}'::jsonb, '{\"metaAttribute\": \"some meta value\"}'::jsonb);" > /dev/null
done

echo
