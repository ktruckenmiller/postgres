!/bin/sh
docker build -t ktruckenmiller/postgres .

docker run --rm -it \
  -e SSM_PATH=/indietools/staging \
  -e S3_BUCKET=kloudcover \
  -e S3_PREFIX=indietools/staging \
  -e IAM_ROLE=postgres-backup \
  ktruckenmiller/postgres \
  backup.sh
