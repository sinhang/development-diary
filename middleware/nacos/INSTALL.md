### nacos


### curl 获取实例
```bash
url -G "http://192.168.1.100:8848/nacos/v1/ns/instance/list" \ \
  --data-urlencode "serviceName=measure-service.grpc" \
  --data-urlencode "groupName=DEFAULT_GROUP" \
  --data-urlencode "accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTc2NzA5OTU2OX0.QuHFJFMHbqwJK9gjIk1_1GCG_wcEc4-6xmTsSceefPI"
```

### curl 删除实例
```bash
curl -X DELETE "http://192.168.1.100:8848/nacos/v1/ns/instance" \
  -d "serviceName=measure-service.grpc" \
  -d "groupName=DEFAULT_GROUP" \
  -d "ip=192.168.1.28" \
  -d "port=9000" \
  -d "accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTc2NzA5OTU2OX0.QuHFJFMHbqwJK9gjIk1_1GCG_wcEc4-6xmTsSceefPI"
```