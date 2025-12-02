#!/bin/bash

set -e

SERVICE_NAME=$1
SONAR_HOST=$2
SONAR_TOKEN=$3

# Example SonarQube scan script
echo "[SONAR] Starting code quality scan..."
sonar-scanner \
-Dsonar.projectKey="${SERVICE_NAME}" \
-Dsonar.sources=./ \
-Dsonar.host.url="${SONAR_HOST}" \
-Dsonar.login="${SONAR_TOKEN}"

