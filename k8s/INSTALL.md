### INSTALL K8S

1. [k8s官网](https://kubernetes.io)
2. [k8s官方安装文档](https://v1-33.docs.kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

### ubuntu 24.04 安装 kubeadm、kubelet 和 kubectl

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/pt/keyrings/
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/pt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/table:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
# 锁定版本
sudo apt-mark hold kubelet kubeadm kubectl

# 检查版本
kubectl version --client
# Client Version: v1.33.6
# Kustomize Version: v5.6.0
```

### 创建集群,master及worker都需要生成配置文件及修改配置文件
```bash
# 生成默认配置
sudo containerd config default | sudo tee /etc/containerd/config.toml
# 编辑配置文件
vi /etc/containerd/config.toml
# 1. 将 [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options] 里面的 SystemdCgroup 设置为 true , 如： SystemdCgroup = true
# 2. 在 [plugins."io.containerd.grpc.v1.cri"] 下面添加如下内容： sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.10"
# 3. 如果存在 [plugins.'io.containerd.cri.v1.images'.pinned_images] 则在下面添加如下内容： sandbox = 'registry.aliyuncs.com/google_containers/pause:3.10'

# 启动 containerd
sudo systemctl restart containerd
# 查看状态
sudo systemctl status containerd
# 测试 CRI 是否可用， 如果输出 json 那么恭喜，CRI 已经可用
sudo crictl info

# 禁用 swap
# 执行： sudo swapoff -a (不需要重启)  
# 或者永久禁用 sudo vim /etc/fstab 将 swap 禁用 
# /swap.img  none  swap  sw  0  0 注释这一行

# 初始化
sudo kubeadm init --image-repository=registry.aliyuncs.com/google_containers --pod-network-cidr=10.244.0.0/16

# 配置 kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 安装网络插件（如 Calico）
sudo ctr -n k8s.io images pull registry.aliyuncs.com/google_containers/pause:3.10
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# 添加节点
# sudo kubeadm init --config kubeadm-config.yaml
# sudo kubeadm token create --print-join-command
# sudo kubeadm join 192.168.1.100:6443 --token 9d5b0c.c0c0c0c0c0c0c0c0 --discovery-token-ca-cert-hash sha256:c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0
# sudo kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# kubectl get pods -n kube-system
# kubectl get nodes
# kubectl get pods -n kube-system
# kubectl get pods -n kube-system | grep metrics-server
# kubectl get pods -n kube-system | grep metrics-server | grep Running
# kubectl get pods -n kube-system | grep metrics-server | grep Running | awk '{print}' | xargs kubectl delete pod -n kube-system
```

### pod错误排查
```bash
# 查看 kube-system 命名空间 pod 状态，所有都在 running 那么恭喜，集群搭建成功
kubectl get pods -n kube-system -o wide
# 如果有错误的 pod 则往下看
# 查看 pods 详情 calico-node-2qk7m 为 pod 名称
kubectl describe pod -n kube-system calico-node-2qk7m

# 如果是拉取容器失败，则使用国内镜像进行拉取，拉取后再导出且导入 cri
```

### 查看 kubelet 日志
```bash
sudo journalctl -u kubelet -n 20 --no-pager
# 如果出现："Container runtime network not ready" networkReady="NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized"
# 那么执行 sudo kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml

# 如果出现 failed to run Kubelet: running with swap on is not supported, please disable swap or set --fail-swap-on flag to false
# 则执行： sudo swapoff -a (不需要重启) 
# 或者永久禁用 sudo vim /etc/fstab 将 swap 禁用 
# /swap.img  none  swap  sw  0  0 注释这一行

```

### 查看容器 - 不需要
```bash
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps -a
# 如果没有则执行:
# 拉 pause 与 control-plane 镜像（按 manifests 实际 image 版本修改 etcd 行）
sudo ctr images pull registry.aliyuncs.com/google_containers/pause:3.10
sudo ctr images pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.33.6
sudo ctr images pull registry.aliyuncs.com/google_containers/kube-controller-manager:v1.33.6
sudo ctr images pull registry.aliyuncs.com/google_containers/kube-scheduler:v1.33.6
sudo ctr images pull registry.aliyuncs.com/google_containers/etcd:3.5.9-0

# 重启 kubelet
sudo systemctl restart kubelet
# 查看容器
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps -a
```

## 查看 containerd 日志
```bash
sudo journalctl -u containerd -n 20 --no-pager
```

### 重置
```bash
sudo kubeadm reset
sudo rm -rf /etc/kubernetes/
sudo rm -rf $HOME/.kube
```


### 下载并且打标签
```bash
# 从国内源手动拉取镜像
# sudo ctr -n k8s.io images pull registry.aliyuncs.com/google_containers/pause:3.10
docker pull registry.cn-hangzhou.aliyuncs.com/calico/cni:v3.25.0

# 重新打标签
docker tag registry.cn-hangzhou.aliyuncs.com/calico/cni:v3.25.0 docker.io/calico/cni:v3.25.0

# 重启 kubelet
sudo systemctl restart kubelet
```

### 查看pod详情
```bash
# kubectl describe pod calico-kube-controllers-7498b9bb4c-nf8cq -n kube-system
kubectl describe pod <pod-name> -n <namespace>
kubectl describe pod kube-apiserver-k8s-master -n kube-system
kubectl describe pod kube-apiserver-k8s-master -n kube-system | grep -i error
kubectl describe pod kube-apiserver-k8s-master -n kube-system | grep -i error | grep -i "cannot"
kubectl describe pod kube-apiserver-k8s-master -n kube-system | grep -i error | grep -i "cannot" | awk '{print $2}' | xargs kubectl delete pod -n kube-system
```

### 查看容器信息
```bash
# 获取 calico-node 容器 ID
sudo crictl ps | grep calico-node

# 查看 calico-node 容器日志（替换为实际的容器ID）
sudo crictl logs <calico-node-container-id>
```

### 外部镜像拉取失败 docker 导出镜像并转 cri 镜像，cri 导入镜像
###### 如果 cri 网络插件无法正常启动且是因为无法拉取镜像则尝试如下操作 - master及worker节点都需要做
```bash

# 网络插件 calico / master 及 worker 节点 都需要
docker pull docker.io/calico/cni:v3.25.0
docker pull docker.io/calico/node:v3.25.0
docker pull docker.io/calico/kube-controllers:v3.25.0

# 然后转换为 containerd 格式
docker save docker.io/calico/cni:v3.25.0 | sudo ctr -n=k8s.io images import -
docker save docker.io/calico/node:v3.25.0 | sudo ctr -n=k8s.io images import -
docker save docker.io/calico/kube-controllers:v3.25.0 | sudo ctr -n=k8s.io images import -

sudo systemctl restart containerd



# 导出镜像
docker save -o calico-cni-v3.25.0.tar calico/cni:v3.25.0
docker save -o calico-node-v3.25.0.tar calico/node:v3.25.0
docker save -o calico-kube-controllers-v3.25.0.tar calico/kube-controllers:v3.25.0

# 转 cri 且导入镜像
sudo ctr -n=k8s.io images import calico-cni-v3.25.0.tar
sudo ctr -n=k8s.io images import calico-node-v3.25.0.tar
sudo ctr -n=k8s.io images import calico-kube-controllers-v3.25.0.tar

# 简化命令
docker save calico/cni:v3.25.0 | sudo ctr -n=k8s.io images import -
```

### crictl 获取容器信息
```bash
sudo crictl ps -a
sudo crictl logs 6b8b8f30c2cad
sudo crictl images | grep calico
sudo crictl images | grep calico | awk '{print}' | xargs sudo crictl rmi
```

### kubectl 指令
```bash
# 获取 命名空间为 kube-system 的 pods
kubectl get pods -n kube-system -o wide
kubectl get pods -n kube-system -o wide | grep calico | awk '{print}' | xargs kubectl delete pod -n kube-system
# 查看 pods 详情
kubectl describe pod -n kube-system calico-node-2qk7m
# 进入 pods
kubectl exec -it ad-service-6479d6c87c-rkmm9 -n fengqi -- /bin/bash
```


### 拉取内部镜像失败
```bash
# Failed to pull image "192.168.1.27:8090/dev/config-service:latest": failed to pull and unpack image "192.168.1.27:8090/dev/config-service:latest": failed to resolve reference "192.168.1.27:8090/dev/config-service:latest": failed to do request: Head "https://192.168.1.27:8090/v2/dev/config-service/manifests/latest": http: server gave HTTP response to HTTPS client

# 新版本
sudo cat <<EOF | sudo tee /etc/containerd/certs.d/192.168.1.100:5000/hosts.toml
server = "http://192.168.1.100:5000"

[host."http://192.168.1.100:5000"]
  capabilities = ["pull", "resolve"]
  skip_verify = true
EOF

# 重启 containerd
sudo systemctl restart containerd

### 如果还不行试试修改配置
sudo vi sudo vi /etc/containerd/config.toml
# 找到下面配置
[plugins.'io.containerd.cri.v1.images'.registry]
  config_path = '/etc/containerd/certs.d:/etc/docker/certs.d'
# 将上面的修改为， 去掉 :/etc/docker/certs.d
[plugins.'io.containerd.cri.v1.images'.registry]
  config_path = '/etc/containerd/certs.d'


### 下面的配置是旧版本的

sudo vi sudo vi /etc/containerd/config.toml
# 找到 
#[plugins."io.containerd.grpc.v1.cri".image_decryption]
#  key_model = "node"
# 在下面添加
    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""

      [plugins."io.containerd.grpc.v1.cri".registry.auths]

      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.1.100:5000".tls]
          insecure_skip_verify = true  # 跳过 HTTPS 验证

      [plugins."io.containerd.grpc.v1.cri".registry.headers]

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."192.168.1.100:5000"]
          endpoint = ["http://192.168.1.100:5000"]

# 重启 containerd
sudo systemctl restart containerd
```

### 查看pod指定行数的日志
```bash
#  kubectl logs -n loki loki-promtail-g4gws --tail=20
kubectl logs -f loki-promtail-g4gws -n loki --tail=10
kubectl logs -f pod_name -n namespace --tail=10
kubectl logs -f pod_name -n namespace --tail=10 | grep "error"
kubectl logs -f pod_name -n namespace --tail=10 | grep "error" | grep "cannot"
```

### 批量删除 pods
```bash
# kubectl delete pods -n loki -l app=loki-promtail
kubectl delete pods -l app=nginx -n nginx
kubectl delete pods -l app=nginx -n nginx --force --grace-period=0
kubectl delete pods -l app=nginx -n nginx --force --grace-period=0 --all
kubectl delete pods -l app=nginx -n nginx --force --grace-period=0 --all --ignore-not-found
kubectl delete pods -l app=nginx -n nginx --force --grace-period=0 --all --ignore-not-found --timeout=5s
kubectl delete pods -l app=nginx -n nginx --force --grace-period=0 --all --ignore-not-found --timeout=5s --wait=false
kubectl delete pods -l app=nginx -n nginx --force --grace-period=0 --all --ignore-not-found --timeout=5s --wait=false --force-deletion
kubectl delete pods -l app=nginx -n nginx --force --grace-period=0 --all --ignore-not-found --timeout=5s --wait=false --force-deletion --force-deletion-propagation=Background
```

### 列出所有的PODS
```bash
kubectl get pods --all-namespaces
kubectl get pods --all-namespaces -o wide
kubectl get pods -A
kubectl get pods -A -o wide
```

### 查看命名空间日志
```bash
kubectl logs -n loki -l app=loki
kubectl logs -n loki -l app=loki-promtail
kubectl logs -n kube-system -l k8s-app=kube-dns
```