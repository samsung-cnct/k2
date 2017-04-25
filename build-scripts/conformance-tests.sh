#!/bin/bash -l
set -x

#  prep the local container with the test files
#  fetch the test files
KUBERNETES_RELEASE_VERSION=$1
PWD=`pwd`
platform=linux
arch=amd64
cache_dir="${PWD}/${KUBERNETES_RELEASE_VERSION}"
mkdir -p "${cache_dir}"
pushd "${cache_dir}"
/google-cloud-sdk/bin/gsutil -mq cp "gs://kubernetes-release/release/${KUBERNETES_RELEASE_VERSION}/kubernetes.tar.gz" .
/google-cloud-sdk/bin/gsutil -mq cp "gs://kubernetes-release/release/${KUBERNETES_RELEASE_VERSION}/kubernetes-test.tar.gz" .
/google-cloud-sdk/bin/gsutil -mq cp "gs://kubernetes-release/release/${KUBERNETES_RELEASE_VERSION}/kubernetes-client-${platform}-${arch}.tar.gz" .
popd

#  unpack the test files
target_dir="${PWD}/kube_tests_dir"
mkdir -p "${target_dir}"
tar -C "${target_dir}" -xzf "${cache_dir}/kubernetes.tar.gz"
tar -C "${target_dir}" -xzf "${cache_dir}/kubernetes-test.tar.gz"
tar -C "${target_dir}/platforms/${platform}/${arch}" -xzf "${cache_dir}/kubernetes-client-${platform}-${arch}.tar.gz"

# setup output dir
OUTPUT_DIR="${PWD}/output"
mkdir -p "${OUTPUT_DIR}/artifacts"

# setup gopath
export GOPATH="${WORKSPACE}/go"
mkdir -p "${GOPATH}"

## run
K2_CLUSTER_NAME=`echo $2 | tr -cd '[[:alnum:]]-'`
export KUBE_CONFORMANCE_KUBECONFIG=${PWD}/cluster/aws/${K2_CLUSTER_NAME}/admin.kubeconfig
export KUBE_CONFORMANCE_OUTPUT_DIR=${OUTPUT_DIR}/artifacts

##DEBUG
echo $PATH


# TODO: unclear what part of k8s scripts require USER to be set
PATH=$PATH:/usr/bin KUBERNETES_PROVIDER=aws USER=jenkins $PWD/hack/parallel-conformance.sh ${target_dir}/kubernetes | tee ${OUTPUT_DIR}/build-log.txt
# tee isn't exiting >0 as expected, so use the exit status of the script directly
conformance_result=${PIPESTATUS[0]}

exit ${conformance_result}