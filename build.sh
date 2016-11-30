#!/bin/sh
if [ -z "$1"]; then
  echo "Gotta put in those params ./build.sh 0.0.1"
else
  docker build -t ktruckenmiller/postgres:$1 .
  docker push ktruckenmiller/postgres:$1
fi
