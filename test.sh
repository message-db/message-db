#!/usr/bin/env bash

test/interactive/database/hash_64.sh

test/interactive/database/write_message.sh
test/interactive/database/write_message_expected_version.sh
test/interactive/database/write_message_expected_version_error.sh

test/interactive/database/get_stream_messages.sh
test/interactive/database/get_category_messages.sh
test/interactive/database/get_last_message.sh
