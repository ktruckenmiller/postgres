#!/bin/sh
s3-cli sync /var/lib/postgresql/data s3://kloudcover/indietools/staging/s3-sync
echo "SYNCED"
