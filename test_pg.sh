#!/bin/sh

docker build -t postgres .

# PG_CONTAINER=$(docker run -it -d \
#   -e IAM_ROLE=arn:aws:iam::601394826940:role/postgres-backup \
#   -e SSM_PATH=/indietools/staging \
#   --rm \
#   -p 5432:5432 \
#   postgres)

docker run -it \
  --link 49249b8b706e:db \
   --entrypoint="" \
   -v $(pwd):/data \
   --workdir=/data \
   -e IAM_ROLE=arn:aws:iam::601394826940:role/postgres-backup \
   -e SSM_PATH=/indietools/staging \
   postgres sh
