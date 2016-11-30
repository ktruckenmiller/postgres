#!/bin/sh
if [ -z "$1" ] &&  [ -z "$2" ]; then
  echo "no args given. restore.sh database_name file_name"
else
  psql $1 < $2
fi
