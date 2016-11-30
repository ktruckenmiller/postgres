#!/bin/sh

CURRENT_VERSION=$(git describe --abbrev=0 --tags)
echo $CURRENT_VERSION
VERSION=$(echo $CURRENT_VERSION | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
echo $VERSION
# docker build -t ktruckenmiller/postgres:$VERSION .
# docker push ktruckenmiller/postgres:$VERSION
# git tag $VERSION
# git push origin --tags
