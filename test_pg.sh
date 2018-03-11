#!/bin/sh

docker build -t postgres .

docker run -it \
  -e IAM_ROLE=arn:aws:iam::601394826940:role/postgres-backup \
  -e SSM_PATH=/indietools/staging \
  -v ~/.aws:/root/.aws \
  --entrypoint="" \
  postgres sh
