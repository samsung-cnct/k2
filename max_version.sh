#!/bin/bash -
#title           :max_version.sh
#description     :Writes the max_version found according to a json_query to a specified file 
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")

QUERY=$1
OUTFILE=$2
shift ; shift
source "${my_dir}/lib/common.sh"

# setup a sigint trap
trap control_c SIGINT

VARS_EXPORT_PATH=/tmp/k2_vars.yaml
ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/max_version.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=max_version version_query=${QUERY} version_outfile=${OUTFILE}" || ( echo "max_version failed" && rm ${VARS_EXPORT_PATH} && exit 1 )
