#!/bin/bash -
#title           :clusterstatus.sh
#description     :common
#author          :Samsung SDSRA
#==============================================================================

#for single cluster. Need choose logic for extendability for multiple clusters.
#parsing config.yaml through bash or using an anisible role. 
CLUSTER_NAME=$(grep -A1 'clusters:' ${KRAKEN_CONFIG} | tail -n1 | awk '{print $3}')

if [ -f ${KRAKEN_BASE}/${CLUSTER_NAME}/admin.kubeconfig ] && [ -f ${KRAKEN_BASE}/${CLUSTER_NAME}/terraform.tfstate ]; then

  inf "Checking cluster status..."

  CLUSTER_NODE_COUNT=$(kubectl --kubeconfig=${KRAKEN_BASE}/${CLUSTER_NAME}/admin.kubeconfig get nodes | wc -l)
  if [ ${CLUSTER_NODE_COUNT} -ge 2 ]; then

    # show current status
    inf  "$(kubectl --kubeconfig=${KRAKEN_BASE}/${CLUSTER_NAME}/admin.kubeconfig get nodes)"

    read -r -p "[ $CLUSTER_NAME ] cluster has been already spinned up. Do you want to continue to update cluster? [ y/N ]:" response
    response=${response,,}    # tolower
    if ! [[ "$response" =~ ^(yes|y)$ ]]; then
      warn "Spinning up cluster has been canceled."
     exit 0
    fi
  fi
fi

warn "Start spinning up cluster..."
