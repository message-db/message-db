#!/usr/bin/env bash

STREAM_NAME=someStream-123 INSTANCES=4 tools/write_message.rb
STREAM_NAME=someStream-456 INSTANCES=4 tools/write_message.rb
STREAM_NAME=someOtherStream-456 INSTANCES=4 tools/write_message.rb
