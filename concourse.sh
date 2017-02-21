#!/bin/bash

set -xe

#  this is an experiment in using concourse CI for building K2
cd k2

#  generate a config file
./up.sh --generate

#  set a cluster name
head -n 3 ~/.kraken/config.yaml
sed -i "bkp" 's/cluster: /cluster: concourse/g' ~/.kraken/config.yaml
head -n 3 ~/.kraken/config.yaml

#  GOGO GADGET
./up.sh

#  DOWN DOWN GADGET
./down.sh