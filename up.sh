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

inf "\nChecking cluster status..."
if [ -f ${KRAKEN_BASE}/cluster.status.lock ]; then
  inf "$(cat ${KRAKEN_CONFIG}/cluster.status.lock)"
  error "Spinning up cluster has been canceled due to its already completed."
  exit 0
fi

# setup a sigint trap
trap control_c SIGINT

DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/up.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=up" --tags "${KRAKEN_TAGS}" || show_post_cluster_error

show_post_cluster
