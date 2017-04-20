#!/bin/sh
#  this script will update the generated config to have all necessary values set

set -x

CLUSTER_NAME="ci"

if [ -z ${env.CHANGE_ID+x} ]; then
  CLUSTER_NAME="${CLUSTER_NAME}-${env.CHANGE_ID}"
else
  CLUSTER_NAME="${CLUSTER_NAME}-${env.BUILD_ID}"
fi



#  old style configs (can be removed after k2recon is merged)
sed -i -e "s/cluster:/cluster: ${CLUSTER_NAME}/" $1

#  new style config
sed -i -e "s/- name:$/- name: ${CLUSTER_NAME}/" $1