#!/bin/bash -
#title           :down.sh
#description     :bring down a kraken cluster
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/lib/common.sh"

# file to capture logs for crash app
log_file=$"/k2-crash-application/logs"

# check if ansible playbook returned error, if so, send to crash app
function crash_test {
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		show_post_cluster_error
		go run /k2-crash-application/crash-app.go $log_file
	else
		show_post_cluster
	fi
}

# exit trap for crash app
trap crash_test EXIT

ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/down.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=down" --tags "${KRAKEN_TAGS}" | tee $log_file
