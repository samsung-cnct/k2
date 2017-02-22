#!/bin/bash

set -xe

#  this is an experiment in using concourse CI for building K2
cd k2

#  generate a config file
./up.sh --generate

#  set a cluster name
conf=~/.kraken/config.yaml
sed -ie 's/cluster:/cluster: concourse/g' $conf

#  write out some keys
keypath=~/.ssh/
mkdir $keypath
echo "$ssh_pub" > $keypath/id_rsa.pub
echo "$ssh_pri" > $keypath/id_rsa

cat $keypath/id_rsa.pub
cat $keypath/id_rsa
exit 0
#  GOGO GADGET
./up.sh

#  DOWN DOWN GADGET
./down.sh