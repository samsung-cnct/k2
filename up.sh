#!/bin/bash -
#title           :up.sh
#description     :bring up a kraken cluster
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/lib/common.sh"

#for single cluster. Need choose logic for extendability for Multiple cluster
CLUSTER_NAME=$(grep -A1 'clusters:' ${KRAKEN_CONFIG} | tail -n1 | awk '{print $3}')
# echo $KRAKEN_CONFIG
# echo $CLUSTER_NAME
CLUSTER_NODE_COUNT=$(kubectl --kubeconfig=${KRAKEN_BASE}/${CLUSTER_NAME}/admin.kubeconfig get nodes | wc -l)
# echo $CLUSTER_NODE_COUNT

if [ ${CLUSTER_NODE_COUNT} -gt 2 ]; then
  read -r -p "[ $CLUSTER_NAME ] cluster has been already spinned up. Do you want to continue to update cluster? [ y/N ]:" response
  response=${response,,}    # tolower
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    warn "Start spinning up cluster."
  else
    warn "Spinning up cluster has been canceled."
   exit 0
  fi
fi


# setup a sigint trap
trap control_c SIGINT

DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/up.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=up" --tags "${KRAKEN_TAGS}" || show_post_cluster_error

show_post_cluster
