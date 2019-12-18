#!/bin/bash
# inspired by https://github.com/istio/istio.io/blob/master/scripts/build_archive_site.sh

currentBranch=$(git rev-parse --abbrev-ref HEAD)

# build legacy archive site (whose files are on disk)
echo "### Building legacy versions (v2.6, v3.0-v3.9)"
git checkout release-legacy
make build

# List of name:tagOrBranch
TOBUILD=(
  v3.11
  v3.10
)

for stream in "${TOBUILD[@]}"; do
    git checkout release-$stream

    echo "### Building $stream"
    make build
done

git checkout $currentBranch
