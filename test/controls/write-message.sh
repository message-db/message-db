source test/controls/stream-name.sh

function write-message {
  local stream_name=${1:-$(stream-nam)}
  local instances=${2:-1}
  STREAM_NAME=$stream_name INSTANCES=$instances database/write-test-message.sh > /dev/null
}


