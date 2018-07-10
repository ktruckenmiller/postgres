#!/bin/sh
echo "Settings creds...."
DB_HOST="0.0.0.0"
DB_NAME=$(ssm_get_parameter $SSM_PATH/db_name)
DB_USER=$(ssm_get_parameter $SSM_PATH/db_user)
DB_PASS=$(ssm_get_parameter $SSM_PATH/db_password)
BACKUP_INTERVAL=${BACKUP_INTERVAL:-"1d"}

echo $DB_HOST:5432:$DB_NAME:$DB_USER:$DB_PASS > ~/.pgpass
chmod 600 ~/.pgpass

set -x

function backup {
  echo "Backing up postgres database $DB_NAME"
  FILE_NAME=$(date +%s).bk
  pg_dump --username=$DB_USER --dbname=$DB_NAME --host $DB_HOST > $FILE_NAME
  echo "Uploading to bucket: $S3_BUCKET with a prefix of $S3_PREFIX/$FILE_NAME"
  aws s3 cp ./$FILE_NAME s3://kloudcover/indietools/staging/$FILENAME
}


function idle {
  echo "ready"
  while true; do
    sleep $BACKUP_INTERVAL &
    wait $!
    [ -n "$BACKUP_INTERVAL" ] && backup
  done
}

trap backup SIGHUP SIGINT SIGTERM
trap "backup; idle" USR1

idle
