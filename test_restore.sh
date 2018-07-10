#!/bin/sh

docker build -t ktruckenmiller/postgres .

docker run --rm -it \
  -e SSM_PATH=/indietools/staging \
  -e S3_BUCKET=kloudcover \
  -e S3_PREFIX=indietools/staging \
  -e IAM_ROLE=arn:aws:iam::601394826940:role/postgres-db \
  -e LOCAL_IP=10.0.1.2 \
  -p 5432:5432 \
  ktruckenmiller/postgres
