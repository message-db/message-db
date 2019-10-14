#!/usr/bin/env bash

set -e

echo
echo "PRINT MESSAGE STORE VERSION"
echo "==========================="
echo "- Retrieve message store database schema version from the message_store_version server function"
echo

database/print-message-store-version.sh

echo "= = ="
echo
