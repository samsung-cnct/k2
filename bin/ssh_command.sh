#!/usr/bin/env bash

USE_HOST_NAME=true

function error {
  echo -e "\033[0;31mERROR: $1\033[0m"
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -c|--command)
  COMMAND="$2"
  shift
  ;;
  -p|--port)
  PORT=22
  shift
  ;;
  -a|--address)
  ADDRESS="$2"
  shift
  ;;
  -u|--user)
  USER_NAME="$2"
  shift
  ;;
  -h|--hostname)
  HOST_NAME="$2"
  shift
  ;;
  -f|--config)
  SSH_CONFIG="$2"
  shift
  ;;
  -v|--verbose)
  VERBOSE=false
  ;;
  *)
  VERBOSE=false
  ;;
esac
shift # past argument or value
done

if [ ! -z "${SSH_CONFIG+x}" ]; then
  SSH_CONFIG="-F ${SSH_CONFIG}"
fi

if [ -z "${COMMAND+x}" ]; then
  error "please enter a valid command"
  exit 1
fi

if [ ! -z "${ADDRESS+x}" ]  && [ ! -z "${USER_NAME+x}" ]; then
  HOST="${USER_NAME}@${ADDRESS} -p ${PORT}"
  USE_HOST_NAME=false
fi

if [ "${USE_HOST_NAME}" == true ]; then
  if [ ! -z "${HOST_NAME+x}" ]; then
    HOST=${HOST_NAME}
  else
    error "please use a hostname(-h) or user(-u)@address(-a) port(-p)"
    exit 1
  fi
fi

if [ -n "${VERBOSE+x}" ]; then
  echo "to run: "
  echo "ssh -tt ${SSH_CONFIG} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${HOST} ${COMMAND}"
fi

ssh -tt ${SSH_CONFIG} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${HOST} ${COMMAND}
