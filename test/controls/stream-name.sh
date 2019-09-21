source test/controls/category.sh

function stream-name {
  local category=${1:-$(category)}
  local uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')
  local stream_name="$category-$uuid"
  echo $stream_name
}
