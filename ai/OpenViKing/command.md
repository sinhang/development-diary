```bash

# 创建 team manager 账号
curl -X POST http://192.168.1.28:1933/api/v1/admin/accounts \
  -H "Content-Type: application/json" \
  -H "X-API-Key: wefawgaerWE" \
  -d '{
    "account_id": "my-team",
    "admin_user_id": "admin"
  }'

# response
# {"status":"ok","result":{"account_id":"my-team","admin_user_id":"admin","user_key":"51a73fa63bc83edf752ab7a12d6612aeb5a7191abc8da66147302a3f6e254d1f"},"error":null,"telemetry":null}
```

```bash
# 创建成员账号
curl -X POST http://192.168.1.28:1933/api/v1/admin/accounts/my-team/users \
  -H "Content-Type: application/json" \
  -H "X-API-Key: 51a73fa63bc83edf752ab7a12d6612aeb5a7191abc8da66147302a3f6e254d1f" \
  -d '{
    "user_id": "self",
    "role": "user"
  }'

# response
# {"status":"ok","result":{"account_id":"my-team","user_id":"self","user_key":"5192f5b99707fdd975e6cb37503a5f199987f825e6df495ad0340c3da16e2601"},"error":null,"telemetry":null}
```

# 容器内部客户端,宿主机则可以按照官方文档来安装
```bash
# 像将 openclaw.json gateway.reload.mode 设置为 off
npx openclaw-openviking-setup-helper
```