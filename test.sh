#!/usr/bin/env bash

set -e

test/print-message-store-version.sh
test/hash-64.sh

test/category/stream-name.sh
test/category/category.sh

test/id/stream-name.sh
test/id/category.sh
test/id/compound-id/stream-name.sh

test/cardinal-id/stream-name-with-compound-id.sh
test/cardinal-id/stream-name-with-single-id.sh
test/cardinal-id/category.sh

test/write-message.sh
test/write-message-expected-version.sh
test/write-message-expected-version-error.sh

test/get-stream-messages.sh
test/get-stream-messages-condition.sh
test/get-stream-messages-correlated.sh
test/get-stream-messages-correlated-stream-name-error.sh

test/get-category-messages.sh
test/get-category-messages-condition.sh
test/get-category-messages-correlated.sh
test/get-category-messages-correlated-stream-name-error.sh

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
