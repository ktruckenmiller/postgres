#!/bin/sh
docker build -t ktruckenmiller/postgres .

docker run --rm -it \
  -e SSM_PATH=/indietools/production \
  -e S3_BUCKET=kloudcover \
  -e S3_PREFIX=indietools/production \
  -e IAM_ROLE=postgres-backup \
  -e FILE_NAME=$1 \
  ktruckenmiller/postgres \
  restore.sh
