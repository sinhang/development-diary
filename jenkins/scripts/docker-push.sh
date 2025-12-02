#!/bin/bash
set -e
REGISTRY_ADDR=$1
IMAGE_NAME=$2


echo "[DOCKER] Pushing image to registry ${REGISTRY_ADDR}/${IMAGE_NAME}:latest"
docker push "${REGISTRY_ADDR}/${IMAGE_NAME}":latest


echo "[DOCKER] Push completed."