#!/bin/bash -x
set -o errexit
set -o nounset
set -o pipefail

die () {
    echo >&2 "$@"
    exit 1
}

while [[ $# > 1 ]]
do
key="$1"

case $key in
  --url|-u)
  URL="$2"
  shift
  ;;
  --prefix|-p)
  PREFIX="$2"
  shift
  ;;
  --lock|-l)
  LOCK="$2"
  shift
  ;;
  *)
  ;;
esac
shift
done

[[ -n ${URL} ]] || die "The --url parameter is required"
PREFIX=${PREFIX:-"/opt/cnct/bin"}
[[ -n ${LOCK} ]] || die "The --lock parameter is required"
BASENAME=$(basename ${URL})
DIRNAME=$(dirname ${URL})
 
if [[ ! -f ${LOCK} ]]
then
  pushd $(pwd)
  cd /tmp

  curl ${DIRNAME}/SHA256SUMS > SHA256SUMS
  curl ${URL} > ${BASENAME}
 
  grep ${BASENAME} SHA256SUMS | sha256sum -c -
  
  mkdir -p ${PREFIX}
  tar --strip-components=1 -C ${PREFIX} -xzf ${BASENAME}

  rm ${BASENAME}
  rm SHA256SUMS
  touch ${LOCK}
  
  popd
fi
