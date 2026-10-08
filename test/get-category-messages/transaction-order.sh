#!/usr/bin/env bash

set -euo pipefail

# Three persistent psql sessions. Completed commands are synchronization barriers;
# no timing sleeps are needed to force the write and commit order.
test_directory=$(mktemp -d)
session_pids=()
cleanup() {
  local pid
  for pid in "${session_pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  for pid in "${session_pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done
  rm -rf "$test_directory"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

for session in a b reader; do
  mkfifo "$test_directory/$session.in" "$test_directory/$session.out"
done
# Open both ends so startup and failure cleanup cannot block on a FIFO open.
exec 3<>"$test_directory/a.in" 4<>"$test_directory/a.out"
exec 5<>"$test_directory/b.in" 6<>"$test_directory/b.out"
exec 7<>"$test_directory/reader.in" 8<>"$test_directory/reader.out"
for session in a b reader; do
  PGCONNECT_TIMEOUT=5 PGOPTIONS="${PGOPTIONS:-} -c statement_timeout=5000" \
    psql -X -qAt -v ON_ERROR_STOP=1 -U message_store message_store \
    < "$test_directory/$session.in" > "$test_directory/$session.out" &
  session_pids+=("$!")
done

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_equal() {
  [[ "$1" == "$2" ]] || fail "$3: expected [$2], got [$1]"
}

command_number=0
result=''
query() {
  local session=$1 sql=$2 input output line marker
  case "$session" in
    a) input=3; output=4 ;;
    b) input=5; output=6 ;;
    reader) input=7; output=8 ;;
    *) fail "Unknown session: $session" ;;
  esac
  command_number=$((command_number + 1))
  marker="command_${command_number}_done"
  printf '%s\n\\echo %s\n' "$sql" "$marker" >&"$input"
  result=''
  while IFS= read -r -t 10 -u "$output" line; do
    [[ "$line" == "$marker" ]] && return 0
    if [[ -n "$result" ]]; then result+=$'\n'; fi
    result+="$line"
  done
  fail "Session $session exited or timed out during: $sql"
}

new_category() {
  query reader "SELECT 'transactionTest' || replace(gen_random_uuid()::text, '-', '');"
  category=$result
}

append() {
  query "$1" "SELECT write_message(gen_random_uuid()::varchar, '$category-$2', 'TransactionTest', '$3');"
}

read_category() {
  query reader "SELECT transaction_id, global_position, data FROM get_category_messages(
    '$category', transaction_position => ${1:-0}, global_position => ${2:-0}, batch_size => ${3:--1});"
}

show_batch() {
  local transaction position data
  printf '\n%s\n' "$1"
  printf '%-20s | %-20s | %s\n' transaction_id global_position data
  printf '%s\n' '---------------------+----------------------+------'
  if [[ -z "$result" ]]; then
    printf '%s\n' '(no messages)'
    return
  fi
  while IFS='|' read -r transaction position data; do
    printf '%-20s | %-20s | %s\n' "$transaction" "$position" "$data"
  done <<< "$result"
}

checkpoint_transaction=0
checkpoint_position=0
consumed=''
poll() {
  local data=''
  read_category "$checkpoint_transaction" "$((checkpoint_position + 1))" 1
  show_batch "$1"
  if [[ -n "$result" ]]; then
    IFS='|' read -r checkpoint_transaction checkpoint_position data <<< "$result"
    consumed+="$data "
  fi
  assert_equal "$data" "$2" "$1"
  printf 'Last processed checkpoint: (%s, %s)\n' "$checkpoint_transaction" "$checkpoint_position"
}

printf '\nTRANSACTION CURSOR: GLOBAL POSITION CAN GO BACKWARDS\n'
printf '%s\n' 'Based on https://gist.github.com/nordfjord/c7784bfaeaae00c9407ec5c1e08423c7'
new_category
append reader baseline 0
poll 'Baseline committed: consume data 0' 0
baseline=$result

# Transaction IDs: baseline < A < B. Global positions: baseline < B < A.
query a 'BEGIN;'
query a 'SELECT pg_current_xact_id();'
transaction_a=$result
query b 'BEGIN;'
append b b 1
query b 'SELECT pg_current_xact_id();'
transaction_b=$result
append a a 2
(( transaction_a < transaction_b )) || fail 'A must allocate its transaction ID before B'
printf '\nA allocated transaction %s first, but B (%s) wrote first.\n' "$transaction_a" "$transaction_b"
poll 'Both transactions open: no new delivery' ''

query a 'COMMIT;'
poll 'A committed; B still open: consume data 2' 2
first=$result
first_global_position=$checkpoint_position
poll 'B still open: polling again does not advance the checkpoint' ''

query b 'COMMIT;'
poll 'B committed: consume data 1 despite its smaller global position' 1
second=$result
(( first_global_position > checkpoint_position )) || fail 'Global position must step backwards'
query reader "SELECT transaction_id, global_position, data FROM messages
  WHERE category(stream_name) = '$category' AND global_position > $first_global_position
  ORDER BY global_position;"
show_batch 'Comparison: resuming by global position alone misses data 1'
assert_equal "$result" '' 'Global-position-only comparison'
assert_equal "$consumed" '0 2 1 ' 'Delivery order'
poll 'Caught up: no duplicate delivery' ''

read_category
show_batch 'Full category in transaction/global-position order'
assert_equal "$result" "$baseline"$'\n'"$first"$'\n'"$second" 'Full category'
printf '%s\n' 'PASS: a global-position-only checkpoint would have skipped data 1.'

# Reverse the commit order: B commits while older A is still open. Its write
# also proves different streams in one category do not block each other.
query a 'BEGIN;'
append a a 3
append b b 4
poll 'Older A open; newer B committed: the visibility gate holds back data 4' ''
query a 'COMMIT;'
poll 'Older A committed: consume data 3 first' 3
poll 'Next page: consume the previously held-back data 4' 4
poll 'Caught up again' ''
assert_equal "$consumed" '0 2 1 3 4 ' 'Delivery across both commit orders'
printf '%s\n' 'PASS: both commit orders preserve complete, duplicate-free delivery.'

# Multiple messages in one transaction must remain pageable even when global
# positions are interleaved with a second transaction's messages.
new_category
query a 'BEGIN;'
append a a 0
append b b 2
read_category
assert_equal "$result" '' 'A newer committed transaction must remain behind the gate'
append a a 1
query a 'COMMIT;'
read_category
rows=$result
IFS=$'\n' read -r -d '' row0 row1 row2 extra <<< "$rows" || true
assert_equal "${extra:-}" '' 'Exactly three messages'
IFS='|' read -r transaction0 position0 data0 <<< "$row0"
IFS='|' read -r transaction1 position1 data1 <<< "$row1"
IFS='|' read -r transaction2 position2 data2 <<< "$row2"
assert_equal "$data0 $data1 $data2" '0 1 2' 'Transaction order'
assert_equal "$transaction0" "$transaction1" 'Messages in one transaction share an ID'
(( position1 > position2 )) || fail 'The transactions must have interleaved positions'
read_category 0 0 1
assert_equal "$result" "$row0" 'First page'
read_category "$transaction0" "$position0" 1
assert_equal "$result" "$row0" 'Cursor is inclusive'
read_category "$transaction0" "$((position0 + 1))" 1
assert_equal "$result" "$row1" 'Resume within a transaction'
read_category "$transaction1" "$((position1 + 1))" 1
assert_equal "$result" "$row2" 'Resume across a transaction boundary'
query reader "SELECT count(*) FROM get_category_messages('$category', NULL, NULL, NULL);"
assert_equal "$result" 3 'NULL defaults'
query reader "SET message_store.debug = 'on';"
read_category
assert_equal "$result" "$rows" 'Debug mode'
query reader "SET message_store.debug = 'off';"
query reader "SELECT transaction_id FROM get_last_stream_message('$category-a');"
assert_equal "$result" "$transaction1" 'Last stream message transaction ID'

# Rollback releases the visibility barrier without delivering the aborted row.
query a 'BEGIN;'
append a a 3
append b b 4
read_category
assert_equal "$result" "$rows" 'Open transaction delays the newer commit'
query a 'ROLLBACK;'
query reader "SELECT string_agg(data, ',' ORDER BY transaction_id, global_position)
  FROM get_category_messages('$category');"
assert_equal "$result" '0,1,2,4' 'Rollback releases the gate without delivering aborted data'

# Stream locks themselves still live until the writing transaction ends.
query a 'BEGIN;'
append a a 5
query b "SELECT pg_try_advisory_xact_lock(hash_64('$category-a'));"
assert_equal "$result" f 'The same stream remains locked'
query a 'ROLLBACK;'
query b "SELECT pg_try_advisory_xact_lock(hash_64('$category-a'));"
assert_equal "$result" t 'Rollback releases the stream lock'
printf '%s\n' 'Transaction ordering, pagination, visibility, and stream locking passed'
