function stream-name {
  local category=${1:-testStream}
  local uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')
  local stream_name="$category-$uuid"
  echo $stream_name
}
