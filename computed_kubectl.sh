#!/bin/bash -
#title          :computed_kubectl
#description    :Calls a version of kubectl whose version is computed by ansible from the provided config, passing along the remaining arguments
#author         :Samsung SDSRA
#====================================================================
set -o errexit
set -o nounset
set -o pipefail

my_dir=$(dirname "${BASH_SOURCE}")
VERSIONFILE=/tmp/$$.maxver
${my_dir}/max_version.sh 'clusters[].nodePools[].kubeConfig.version' ${VERSIONFILE} -c $1
shift
/opt/cnct/kubernetes/`cat ${VERSIONFILE} | cut -d . -f 1-2`/bin/kubectl $@
