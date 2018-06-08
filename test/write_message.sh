#!/usr/bin/env bash

echo
echo "WRITE MESSAGE"
echo "============="
echo

stream_name=$(uuidgen)

STREAM_NAME=$stream_name database/write-test-message.sh

psql message_store -P pager=off -c "SELECT * FROM messages WHERE stream_name = '$stream_name';"

echo "= = ="
echo
