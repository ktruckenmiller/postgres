!/bin/sh
docker build -t ktruckenmiller/postgres .

docker run --rm -it \
  -e SSM_PATH=/indietools/staging \
  -e AWS_REGION=us-west-2 \
  -e S3_BUCKET=kloudcover \
  -e S3_PREFIX=indietools/staging \
  -e IAM_ROLE=indietools-staging-IndietoolsRole-25NMYZLSD87N \
  ktruckenmiller/postgres \
  sh
