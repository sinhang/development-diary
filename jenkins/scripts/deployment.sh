#!/bin/bash

set -e

WORKSPACE=$1
ENV=$2
SERVICE_NAME=$3
NAMESPACE=$4

echo "[DOCKER] ${WORKSPACE} Deployment..."

# 判断 ${WORKSPACE}/deployment.${ENV}.yml 文件是否存在
if [ ! -f "${WORKSPACE}/deployment.${ENV}.yml" ]; then
  echo "[DOCKER] ${WORKSPACE}/deployment.${ENV}.yml not found."
  exit 1
fi

kubectl apply -f "${WORKSPACE}/deployment.${ENV}.yml"
kubectl rollout restart deployment ${SERVICE_NAME##*/} -n "${NAMESPACE}-${ENV}"


echo "[DOCKER] Deployment completed."