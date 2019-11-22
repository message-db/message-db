function compound-id-stream-name {
  local category=${1:-$(category)}
  local uuid_1=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')
  local uuid_2=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')
  local stream_name="$category-$uuid_1+$uuid_2"
  echo $stream_name
}
