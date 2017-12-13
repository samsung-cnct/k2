#!/bin/sh

# to run locally
# export CI_PROJECT_DIR=$"<local_directory>"

./bin/up.sh --generate --config $CI_PROJECT_DIR/cluster/$1/config.yaml

build-scripts/update-generated-config.sh $CI_PROJECT_DIR/cluster/$1/config.yaml krakenlib-$CI_PIPELINE_ID