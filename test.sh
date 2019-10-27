#!/usr/bin/env bash

set -e

test/print-message-store-version.sh
test/category.sh
test/hash-64.sh

test/write-message.sh
test/write-message-expected-version.sh
test/write-message-expected-version-error.sh

test/get-stream-messages.sh
test/get-stream-messages-correlated.sh
test/get-category-messages.sh
test/get-category-messages-correlated.sh
test/get-last-message.sh

test/print-messages.sh
test/print-stream-summary.sh
test/print-type-summary.sh
test/print-stream-type-summary.sh
test/print-type-stream-summary.sh
test/print-category-type-summary.sh
test/print-type-category-summary.sh

echo "DONE"
echo
