#!/bin/bash
set -e

APISIX_ROUTE_ADMIN=$1
APISIX_PROTO_ADMIN=$2
API_KEY=$3
SERVICE_NAME=$4

# 拼接 SERVICE_NAME
SERVICE_NAME="${SERVICE_NAME}.grpc"

SERVICE_PART=$(echo "$SERVICE_NAME" | cut -d'-' -f1)

# proto 文件目录
PROTO_DIR="./api"

# 确保 apisix 目录存在
mkdir -p apisix

# 遍历所有 proto 文件
find "$PROTO_DIR" -type f -name "*.proto" | while read -r PROTO_FILE; do
#  echo "===> 处理 proto 文件: $PROTO_FILE"
  # 提取文件名（不含路径和扩展名）
  PROTO_NAME=$(basename "$PROTO_FILE" .proto)

  PB_FILE="apisix/${PROTO_NAME}.pb"
  /var/jenkins_home/protoc/bin/protoc --proto_path=. --proto_path=./third_party --include_imports --descriptor_set_out="${PB_FILE}" "${PROTO_FILE}"
  # 提取 package
  PACKAGE=$(grep -E "^package " "$PROTO_FILE" | awk '{print $2}' | sed 's/;//')

  # 提取所有 service
  grep -E "^service " "$PROTO_FILE" | awk '{print $2}' | sed 's/ {//' | while read -r SERVICE; do
    PROTO_SERVICE="${PACKAGE}.${SERVICE}"
    PROTO_ID=$(echo "$PROTO_SERVICE" | sed 's/\./-/g' | sed 's/-/./g' | sed 's/\./-/g')
#    echo "  --> 发现 service: $PROTO_SERVICE $PROTO_ID"
    API_VERSION=$(echo "$PROTO_SERVICE" | cut -d'.' -f3)

    curl "${APISIX_PROTO_ADMIN}/${PROTO_SERVICE}" \
    -H "X-API-KEY: ${API_KEY}" -X PUT -d '
    {
        "content" : "'"$(base64 -w0 "${PB_FILE}")"'"
    }'

    # 提取该 service 下的所有 rpc 方法
    # 提取该 service 下的所有 rpc 方法
    sed -n '/service '"$SERVICE"' {/,/}/p' "$PROTO_FILE" | grep -E "rpc " | awk '{print $2}' | while read -r METHOD; do

      # 提取方法名（去除参数部分）
      METHOD_NAME=$(echo "$METHOD" | cut -d'(' -f1)

      # 提取HTTP动词前缀
      PREFIX=$(echo "$METHOD_NAME" | sed -E 's/(^[A-Z][a-z]*).*/\1/')
      echo "  --> 提取方法名: $METHOD_NAME -> $PREFIX"

      # 定义支持的HTTP方法列表
      case "${PREFIX}" in
        Get|Post|Put|Delete|Patch|Head|Options)
          # 转换为大写
          PREFIX_UPPER=$(echo "${PREFIX}" | tr '[:lower:]' '[:upper:]')
          # 提取剩余部分作为后缀
          SUFFIX_ORIGINAL=$(echo "$METHOD_NAME" | sed -E "s/^${PREFIX}//")
          SUFFIX_LOWER=$(echo "$SUFFIX_ORIGINAL" | sed 's/^\(.\)/\L\1/')
          echo "    --> 处理方法: $SUFFIX_LOWER"
          ;;
        *)
          # 不是标准HTTP方法前缀，跳过该方法，但继续处理其他方法
          echo "    --> 跳过方法: $METHOD (不支持的HTTP方法前缀: $PREFIX)"
          continue
          ;;
      esac

  # 其余处理逻辑...


      #      echo "    --> 处理方法: $METHOD"
      # 提取 Get 并转为大写 (GET)
      PREFIX_UPPER=$(echo "$METHOD" | cut -d'(' -f1 | sed -E 's/(^[A-Z][a-z]*).*/\1/' | tr '[:lower:]' '[:upper:]')

      # 提取 Detail 保留原样 (Detail)
      SUFFIX_ORIGINAL=$(echo "$METHOD" | cut -d'(' -f1 | sed -E 's/^[A-Z][a-z]*([A-Z][a-z]*)/\1/')
      SUFFIX_LOWER=$(echo "$SUFFIX_ORIGINAL" | sed 's/^\(.\)/\L\1/')
      # 提取 Detail 并转为小写 (detail)
      # METHOD 转驼峰
      echo "    --> 处理方法: $SUFFIX_LOWER"
#      SUFFIX_LOWER=$(echo "$METHOD" | cut -d'(' -f1 | sed -E 's/^[A-Z][a-z]*([A-Z][a-z]*)/\1/' | tr '[:upper:]' '[:lower:]')

      #SUFFIX_LOWER=$(echo "$METHOD" | cut -d'(' -f1 | sed -E 's/^[A-Z][a-z]*([A-Z][a-z]*)/\1/' | tr '[:upper:]' '[:lower:]')

      METHOD_NAME=$(echo "$METHOD" | cut -d'(' -f1)

#      SERVICE_LOWER=$(echo "$SERVICE" | tr '[:upper:]' '[:lower:]')
      SERVICE_LOWER=$(echo "$SERVICE" | sed 's/^\(.\)/\L\1/')
      SERVICE_PART_LOWER=$(echo "$SERVICE_PART" | tr '[:upper:]' '[:lower:]')

      URI="/${SERVICE_PART_LOWER}/${API_VERSION}/${SERVICE_LOWER}/${SUFFIX_LOWER}"  # service 转小写，URI 风格可根据需要调整
      # 如果 SUFFIX_LOWER == index 那么不拼接 SUFFIX_LOWER
      # 截取 suffix 里面的  /index
#      if [[ "$SUFFIX_LOWER" == "index" ]]; then
#        URI="/${SERVICE_PART_LOWER}/${API_VERSION}/${SERVICE_LOWER}"
#      fi
      echo "    --> 注册路由: $URI"
      ROUTE_ID=$(echo "$URI" | sed 's/^\///' | tr '/' '-')
#      echo "    --> 注册路由: $SERVICE_PART $URI"
#      echo "原始方法: $METHOD"
#      echo "方法: $METHOD_NAME"
#      echo "前缀(大写): $PREFIX_UPPER"      # 输出: GET
#      echo "后缀(原样): $SUFFIX_ORIGINAL"    # 输出: Detail
#      echo "后缀(小写): $SUFFIX_LOWER"      # 输出: detail
#      echo "路由ID: $ROUTE_ID"      # 输出: detail
#      echo "PROTO ID: $PROTO_ID"      # 输出: detail

      if [[ "$(basename "$PROTO_FILE")" == "login.proto" || "$(basename "$PROTO_FILE")" == "home.proto" || "$(basename "$PROTO_FILE")" == "talk.proto" || "$(basename "$PROTO_FILE")" == "profile.proto"
      || "$METHOD_NAME" == "PostForget" || "$METHOD_NAME" == "PostForgetSmsSend"
      || "$SERVICE_NAME" == "article-service" || "$SERVICE_NAME" == "search-service" || "$SERVICE_NAME" == "ad-service" || "$SERVICE_NAME" == "home-service" || "$SERVICE_NAME" == "config-service" ]]; then
        # 包含 login 的 proto 文件，不添加 rs256-jwt-auth 插件
        JWT_PLUGIN=""
      else
        # 不包含 login 的 proto 文件，添加 rs256-jwt-auth 插件
        JWT_PLUGIN=',"rs256-jwt-auth":{"token_header":"Authorization","user_id_header":"X-User-ID","public_key_path":"/usr/local/apisix/conf/public.pem"}'
      fi
      curl "${APISIX_ROUTE_ADMIN}/admin/routes/${ROUTE_ID}" \
      -H "X-API-KEY: ${API_KEY}" \
      -X PUT -d '
      {
          "name": "'"$PROTO_SERVICE.$SUFFIX_LOWER"'",
          "uri": "'"/api$URI"'",
          "methods": ["'"$PREFIX_UPPER"'"],
          "plugins": {
              "aes-request-decode": {},
              "grpc-transcode": {
                  "proto_id": "'"$PROTO_SERVICE"'",
                  "service": "'"$PROTO_SERVICE"'",
                  "method": "'"$METHOD_NAME"'",
                  "show_status_in_body": true
              },
              "aes-response-encode": {}'"$JWT_PLUGIN"'
          },
          "upstream": {
              "service_name": "'"$SERVICE_NAME"'",
              "type": "roundrobin",
              "discovery_type": "nacos",
              "scheme": "grpc"
          }
      }'
    done
  done
done