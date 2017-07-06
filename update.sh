#!/bin/bash -
#title           :update.sh
#description     :update kubernetes version on AWS after changing config file to new version
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/lib/common.sh"

# if [ -z $UPDATE_NODEPOOLS ]; then
#   error "--nodepools flag must be used"
#   exit 1
# fi
# setup a sigint trap
trap control_c SIGINT

# capture logs for crash app
crash_app_dir=$"/usr/bin/k2-crash-app"
logs=$"logs"
log_file=$crash_app_dir/$logs

# exit trap for crash app
trap crash_test_update EXIT

# check crash application directory exists
if [ -d "$crash_app_dir" ]; then
	DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/update.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=update" | tee $log_file
else 
	DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/update.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=update" || show_update_error
fi

show_update
