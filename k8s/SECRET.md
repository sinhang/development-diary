```bash
kubectl create secret docker-registry harbor \
  --docker-server=192.168.1.100:5000 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  --docker-email=secret@qq.com \
  -n namespace
```