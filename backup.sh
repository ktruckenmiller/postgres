#!/bin/sh

if [ -z "$1" ] &&  [ -z "$2" ]; then
  echo "Make sure you pass args. ./backup.sh user_name db_name file_path"
else
  pg_dump --username=$1 --dbname=$2 > $1
fi
