#!/bin/sh

CURRENT_VERSION=$(git describe --abbrev=0 --tags)

VERSION=$(echo $CURRENT_VERSION | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')

docker build -t ktruckenmiller/postgres:$VERSION .
docker push ktruckenmiller/postgres:$VERSION
git tag $VERSION
git push origin --tags
