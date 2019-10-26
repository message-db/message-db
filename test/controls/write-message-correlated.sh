function write-message-correlated {
  local stream_name=${1:-$(stream-name)}
  local instances=${2:-1}
  local correlation_stream_name=${3:-"someCorrelation"}

  if [ ! -z ${CORRELATION+x} ]; then
    correlation_stream_name=$CORRELATION
  fi

  metadata="'{\"correlationStreamName\": \"$correlation_stream_name\"}'"

  METADATA=$metadata STREAM_NAME=$stream_name INSTANCES=$instances database/write-test-message.sh > /dev/null
}
