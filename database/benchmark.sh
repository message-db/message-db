#!/usr/bin/env bash

set -u

uuid=$(echo $(uuidgen) | tr '[:upper:]' '[:lower:]')

stream_name="testStream-$uuid"
if [ ! -z ${STREAM_NAME+x} ]; then
  stream_name=$STREAM_NAME
fi

cycles=1000
if [ ! -z ${CYCLES+x} ]; then
  cycles=$CYCLES
fi

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}

base=$(script_dir)

echo
echo "Benchmark $cycles cycles (Stream Name: $stream_name)"
echo "= = ="
echo

default_name=message_store

if [ -z ${DATABASE_USER+x} ]; then
  echo "(DATABASE_USER is not set)"
  user=$default_name
else
  user=$DATABASE_USER
fi
echo "Database user is: $user"

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set)"
  database=$default_name
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"
echo

echo "Installing benchmark scripts"
echo

psql $database -f $base/benchmark_write.sql
psql $database -f $base/benchmark_get.sql

echo
echo "Benchmarking write"
echo "- - -"
echo

psql $database -c "EXPLAIN ANALYZE SELECT benchmark_write('$stream_name'::varchar, $cycles::int);"

echo


echo
echo "Benchmarking get"
echo "- - -"
echo

psql $database -c "EXPLAIN ANALYZE SELECT benchmark_get('$stream_name'::varchar, $cycles::int);"

echo
