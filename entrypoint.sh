#!/usr/bin/env bash
POSTGRES_DB=$(ssm_get_parameter $SSM_PATH/db_name)
POSTGRES_USER=$(ssm_get_parameter $SSM_PATH/db_user)
POSTGRES_PASSWORD=$(ssm_get_parameter $SSM_PATH/db_password)
set -e


KEY=`aws s3 ls s3://kloudcover$SSM_PATH/ | sort | tail -n 1 | awk '{print $4}'`
aws s3 cp s3://kloudcover$SSM_PATH/$KEY /tmp/backup.bk

psql -v ON_ERROR_STOP=1 <<-EOSQL
     CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
     CREATE DATABASE $POSTGRES_DB;
     GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
EOSQL
set +e
psql --username=$POSTGRES_USER --dbname=$POSTGRES_DB < /tmp/backup.bk
