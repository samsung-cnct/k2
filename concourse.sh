#!/bin/bash

set -xe

#  this is an experiment in using concourse CI for building K2
cd k2

#  generate a config file
./up.sh --generate

#  set a cluster name
conf=~/.kraken/config.yaml
head -n 3 $conf
sed -ie 's/cluster:/cluster: concourse/g' $conf
head -n 3 $conf

#  GOGO GADGET
./up.sh

#  DOWN DOWN GADGET
./down.sh