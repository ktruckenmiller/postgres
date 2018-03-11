#!/bin/bash

set -e

REMOTE=s3://kloudcover$SSM_PATH/postgres-sync
LOCAL=/data

function backup {
  echo "backup $LOCAL => $REMOTE"
  if ! aws s3 sync "$LOCAL" "$REMOTE" --delete; then
    echo "backup failed" 1>&2
    return 1
  fi
}

function final_backup {
  echo "backup $LOCAL => $REMOTE"
  while ! aws s3 sync "$LOCAL" "$REMOTE" --delete; do
    echo "backup failed, will retry" 1>&2
    sleep 1
  done
  exit 0
}

function idle {
  echo "ready"
  while true; do
    sleep ${BACKUP_INTERVAL:-42} &
    wait $!
    [ -n "$BACKUP_INTERVAL" ] && backup
  done
}

restore

trap final_backup SIGHUP SIGINT SIGTERM
trap "backup; idle" USR1

idle
