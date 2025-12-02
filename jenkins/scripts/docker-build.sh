#!/bin/bash
set -e
REGISTRY_ADDR=$1
IMAGE_NAME=$2

echo "[DOCKER] Building image ${REGISTRY_ADDR}/${IMAGE_NAME}:latest"
docker build -t "${REGISTRY_ADDR}/${IMAGE_NAME}":latest .

echo "[DOCKER] Build completed."