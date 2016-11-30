#!/bin/sh
if [ -z "$1" ] &&  [ -z "$2" ]; then
  echo "no args given. `/restore.sh user_name database_name file_name`"
else
  psql --username=$1 --dbname=$2 < $3
fi
