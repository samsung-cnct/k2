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

# setup a sigint trap
trap control_c SIGINT

# capture logs for crash app
log_file=$"/k2-crash-application/logs"

# check if ansible return failure
# if failure, send to crash app
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

DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/up.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=up" --tags "${KRAKEN_TAGS}" | tee $log_file