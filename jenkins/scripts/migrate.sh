#!/bin/bash

set -e

MYSQL_DSN=$1
MIGRATE_PATH=$2


echo "[MIGRATE] Running ${MIGRATE_PATH} database migration..."
# 判断 ${MIGRATE_PATH} 目录是否存在，存在则执行 migrate
if [ -d "${MIGRATE_PATH}" ]; then
  /var/jenkins_home/go-workspace/bin/migrate -path "${MIGRATE_PATH}" -database "${MYSQL_DSN}" up
  echo "[MIGRATE] Migration completed."
else
  echo "[MIGRATE] ${MIGRATE_PATH} directory does not exist."
fi

echo "[MIGRATE] Migration completed."