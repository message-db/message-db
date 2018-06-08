#!/usr/bin/env bash

test/setup.sh

psql message_store -P pager=off -c "select * from get_last_message('someStream-123');"
