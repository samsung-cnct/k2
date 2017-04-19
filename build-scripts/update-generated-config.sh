#!/bin/sh
#  this script will update the generated config to have all necessary values set

set -x

CLUSTER_NAME="ci"

if [[ "x${ghprbPullId}" != "x" ]]; then
  CLUSTER_NAME="${CLUSTER_NAME}-${ghprbPullId}"
else
  CLUSTER_NAME="${CLUSTER_NAME}-${BUILD_NUMBER}"
fi



#  old style configs (can be removed after k2recon is merged)
sed -i -e "s/cluster:/cluster: ${CLUSTER_NAME}/" $1

#  new style config
sed -i -e "s/- name:$/- name: ${CLUSTER_NAME}/" $1