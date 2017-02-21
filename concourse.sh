#!/bin/bash

set -xe

#  this is an experiment in using concourse CI for building K2

cwd=`pwd`

#  generate a config file
${cwd}/k2/up.sh --generate

#  set a cluster name
sed -i 's/cluster: /cluster: concourse/g' ~/.kraken/config.yaml

#  GOGO GADGET
${cwd}/k2/up.sh

#  DOWN DOWN GADGET
${cwd}/k2/down.sh