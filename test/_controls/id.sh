function id {
  local uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')
  echo $uuid
}
