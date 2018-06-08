#!/usr/bin/env bash

STREAM_NAME=someStream-123 INSTANCES=4 database/write-test-message.sh
STREAM_NAME=someStream-456 INSTANCES=4 database/write-test-message.sh
STREAM_NAME=someOtherStream-456 INSTANCES=4 database/write-test-message.sh
