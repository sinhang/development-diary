### INSTALL LOKI

### 下载镜像
```bash
docker pull grafana/loki:3.5.8
docker pull grafana/promtail:3.5.8
```

### 导出镜像
```bash
mkdir loki
cd loki
docker save grafana/loki:3.5.8 -o grafana-loki.3.5.8.tar
docker save grafana/promtail:3.5.8 -o grafana-promtail.3.5.8.tar
```

### 导入镜像
```bash
sudo ctr -n=k8s.io images import grafana-loki.3.5.8.tar
sudo ctr -n=k8s.io images import grafana-promtail.3.5.8.tar
```

### 创建命名空间
```bash
# Create namespace
kubectl create namespace loki
```

### 创建 loki
```bash
# Create loki
kubectl apply -f loki-config.yml
# Create promtail
kubectl apply -f promtail-config.yml
# Create promtail service account
kubectl apply -f promtail-service-account.yml
```

### 错误检查
```bash
kubectl logs -n loki loki-0 -f
```

### helm 安装
```bash
kubectl get pods -n loki -o wide
NAME                  READY   STATUS    RESTARTS   AGE     IP               NODE              NOMINATED NODE   READINESS GATES
loki-0                1/1     Running   0          9m32s   10.244.111.231   fengqi-w580-g20   <none>           <none>
loki-promtail-hhk49   1/1     Running   0          9m32s   10.244.183.68    fengqi-27         <none>           <none>
loki-promtail-s7mn2   1/1     Running   0          9m32s   10.244.111.194   fengqi-w580-g20   <none>           <none>
```

### 查看 service
```bash
kubectl get svc -n loki
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
loki               NodePort    10.96.116.103   <none>        3100:31000/TCP   63s
loki-gossip-ring   ClusterIP   None            <none>        7946/TCP         14m
```