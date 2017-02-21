#!/bin/bash

set -xe

#  this is an experiment in using concourse CI for building K2

k2Dir=`pwd`\k2

#  generate a config file
${k2Dir}/up.sh --generate

#  set a cluster name
sed -i 's/cluster: /cluster: concourse/g' ~/.kraken/config.yaml

#  GOGO GADGET
${k2Dir}/up.sh

#  DOWN DOWN GADGET
${k2Dir}/down.sh