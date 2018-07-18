#!/usr/bin/env bash

test/hash-64.sh

test/write-message.sh
test/write-message-expected-version.sh
test/write-message-expected-version-error.sh

test/get-stream-messages.sh
test/get-category-messages.sh
test/get-last-message.sh
test/get-stream-summary.sh
