#!/bin/sh
git add .

CURRENT_VERSION=$(git describe --abbrev=0 --tags)
VERSION=$(echo $CURRENT_VERSION | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
git commit -m "Trying to upgrade to $VERSION"
docker build -t ktruckenmiller/postgres:$VERSION .
docker push ktruckenmiller/postgres:$VERSION
docker tag ktruckenmiller/postgres:$VERSION ktruckenmiller/postgres:latest
docker push ktruckenmiller/postgres:latest
git push
git tag $VERSION
git push origin --tags
