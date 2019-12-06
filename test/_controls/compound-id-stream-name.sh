function compound-id-stream-name {
  local category=${1:-$(category)}
  local cardinal_id=${2:-$(id)}
  local stream_name="$category-$cardinal_id+$(id)"
  echo $stream_name
}
