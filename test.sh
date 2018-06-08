#!/usr/bin/env bash

test/hash_64.sh

test/write_message.sh
test/write_message_expected_version.sh
test/write_message_expected_version_error.sh

test/get_stream_messages.sh
test/get_category_messages.sh
test/get_last_message.sh
