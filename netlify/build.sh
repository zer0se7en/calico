#!/bin/bash
set -e

if [ -z "$(which jekyll)" ]; then
    gem install github-pages
fi

if [ -z "$(which helm)" ]; then
    make bin/helm
    export PATH=$PATH:$(pwd)/bin
fi

DESTINATION=$(pwd)/_site

JEKYLL_CONFIG=_config.yml
if [ "$CONTEXT" == "deploy-preview" ]; then
    echo "url: $DEPLOY_PRIME_URL" >_config_url.yml
    JEKYLL_CONFIG=$JEKYLL_CONFIG,$(pwd)/_config_url.yml
fi

function build() {
    config=$JEKYLL_CONFIG
    if [ "$SITE" == "archive" ]; then
        echo "archive: true" >_config_jekyll.yml
        config=$JEKYLL_CONFIG,$(pwd)/_config_jekyll.yml
    fi
    echo "building site"
    jekyll build --config $config --incremental
}

function build_release() {
    echo "building $1"
    TEMP_DIR=$(mktemp -d)
    # git archive --format=tar origin/$1 | (cd $TEMP_DIR && tar xf -)
    git clone --depth=1 https://github.com/projectcalico/calico -b $1 $TEMP_DIR

    pushd $TEMP_DIR
    jekyll build --config $JEKYLL_CONFIG
    popd

    rsync -r $TEMP_DIR/_site .
}


build

if [ "$SITE" == "archive" ]; then
    grep -oP '^- \K(.*)' _data/archives.yml | xargs -I _ echo release-_ | while read branch; do
        if [[ "$branch" == release-legacy*  ]]; then
            branch="release-legacy"
        fi
        build_release $branch
    done
fi

if [ "$SITE" == "latest" ]; then
    cp netlify/_redirects _site
fi
