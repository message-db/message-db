#!/usr/bin/env bash

STREAM_NAME=someStream-123 INSTANCES=4 test/write_message.sh
STREAM_NAME=someStream-456 INSTANCES=4 test/write_message.sh
STREAM_NAME=someOtherStream-456 INSTANCES=4 test/write_message.sh
