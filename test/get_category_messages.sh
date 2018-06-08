#!/usr/bin/env bash

test/setup.sh

psql message_store -P pager=off -c "select * from get_category_messages('someStream', 4, 1, _condition => 'position = 3');"
