### open many files panic

### master 及 node 节点设置文件描述符数
```bash
sudo mkdir -p /etc/systemd/system/containerd.service.d
sudo vi /etc/systemd/system/containerd.service.d/override.conf
# 写入
[Service]
LimitNOFILE=1048576

sudo systemctl daemon-reexec
sudo systemctl restart containerd
sudo systemctl restart kubelet
```

### 验证
```bash
systemctl show containerd -p LimitNOFILE
```
### 输出
```
LimitNOFILE=1048576
```

### 创新创建 pod 即可
```bash
# pod 内部验证文件描述符数
ulimit -n
# 输出
1048576
```