#!/usr/bin/env bash

test/hash-64.sh

test/write-message.sh
test/write-message-expected-version.sh
test/write-message-expected-version-error.sh

test/get-stream-messages.sh
test/get-category-messages.sh
test/get-last-message.sh
test/get-stream-summary.sh
test/get-type-summary.sh

test/print-messages.sh
test/print-stream-summary.sh
test/print-type-summary.sh
test/print-type-stream-summary.sh
test/print-stream-type-summary.sh
