### DNS

### 指令
```bash
# 查看 CoreDNS Pod 是否正常
kubectl -n kube-system get pods -l k8s-app=kube-dns

# 查看 CoreDNS 日志
kubectl -n kube-system logs -l k8s-app=kube-dns
```

### 如果日志出现
```
k8s pod 
ERROR ts=2025-11-27T11:08:51Z caller=dispatcher/dispatcher.go:46 service.id=ai-service-79468dcfb8-cck9f service.name=ai-service service.version=v0.0.1-34-g027052b trace.id= span.id= module=cqrs.subscriber.task.created msg=Consumer task.created failed to process message: Get "https://www.baidu.com": dial tcp: lookup www.baidu.com on xxx.xx.x.xx: server misbehaving
```

### 修改 DNS 配置
```bash
kubectl -n kube-system edit configmap coredns
# 将 forward . 行修改为
forward . 223.5.5.5 114.114.114.114 8.8.8.8
```

### 重启 CoreDNS Pod
```bash
kubectl -n kube-system rollout restart deployment coredns
```