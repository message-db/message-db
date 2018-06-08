#!/usr/bin/env bash

psql message_store -c "SELECT hash_64('someStream-123');"
