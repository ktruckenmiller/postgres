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
pg_dump --username=$DB_USER --dbname=$DB_NAME --host $DB_HOST > $FILE_NAME
echo "Uploading to bucket: $S3_BUCKET with a prefix of $S3_PREFIX/$FILE_NAME"
s3 put --bucket $S3_BUCKET --prefix $S3_PREFIX --file-name $FILE_NAME
