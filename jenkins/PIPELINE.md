### pipeline steps

1. 拉取代码
2. jenkins 主机执行 `"./scripts/sonar.sh"` 进行代码质量检测
3. jenkins 主机将指定目录下面的文件夹传至远程主机
4. jenkins 主机执行 `"./scripts/apisix.sh ${APISIX_KEY}"` 将路由添加至 `apisix`
5. 远程主机执行 `"/home/fengqi/soft/docker/jenkins_work/scripts/migrate.sh ${MYSQL_DSN} ${MIGRATE_PATH}"` 将数据库迁移至 `mysql`
6. jenkins 主机执行 `"./scripts/docker-build.sh ${REGISTRY_ADDR} ${JOB_NAME}"` 构建镜像
7. jenkins 主机执行 `"./scripts/docker-PUSH.sh ${REGISTRY_ADDR} ${JOB_NAME}"` 将推送镜像至仓库
8. 远程主机执行 `/home/fengqi/soft/docker/jenkins_work/scripts/deployment.sh` 进行部署
9. 邮件通知构建结果