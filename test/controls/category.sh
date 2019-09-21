function category {
  local uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')
  local category_suffix=${uuid:0:8}
  local category="${1:-testStream}X$category_suffix"
  echo $category
}
