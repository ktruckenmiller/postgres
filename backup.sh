#!/bin/sh
echo "Settings creds...."
DB_HOST=$(ssm_get_parameter $SSM_PATH/db_host)
DB_NAME=$(ssm_get_parameter $SSM_PATH/db_name)
DB_USER=$(ssm_get_parameter $SSM_PATH/db_user)
DB_PASS=$(ssm_get_parameter $SSM_PATH/db_password)


echo $DB_HOST:5432:$DB_NAME:$DB_USER:$DB_PASS > ~/.pgpass
chmod 600 ~/.pgpass

echo "Backing up postgres database $DB_NAME"
FILE_NAME=$(date +%s).bk
pg_dump --username=$DB_USER --dbname=$DB_NAME --host $DB_HOST > $FILE_NAME.bk

s3 put -b $S3_BUCKET -k $S3_PREFIX/$DATE.bk -p $FILE_NAME --endpoint s3.dualstack.us-west-2.amazonaws.com
