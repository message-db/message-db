function stream-name {
  local category=${1:-$(category)}
  local stream_name="$category-$(id)"
  echo $stream_name
}
