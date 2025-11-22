### INSTALL K8S

1. [k8s官网](https://kubernetes.io)
2. [k8s官方安装文档](https://v1-33.docs.kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

### ubuntu 24.04 安装 kubeadm、kubelet 和 kubectl

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
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

### 创建集群
```bash
# 生成默认配置
sudo containerd config default | sudo tee /etc/containerd/config.toml
# 编辑配置文件
vi /etc/containerd/config.toml
# 1. 将 [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options] 里面的 SystemdCgroup 设置为 true , 如： SystemdCgroup = true
# 2. 在 [plugins."io.containerd.grpc.v1.cri"] 下面添加如下内容：sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.10"
# 3. 如果存在 [plugins.'io.containerd.cri.v1.images'.pinned_images] 则在下面添加如下内容：sandbox = 'registry.aliyuncs.com/google_containers/pause:3.10'

# 启动 containerd
sudo systemctl restart containerd
# 查看状态
sudo systemctl status containerd
# 测试 CRI 是否可用， 如果输出 json 那么恭喜，CRI 已经可用
sudo crictl info

# 初始化
sudo kubeadm init --image-repository=registry.aliyuncs.com/google_containers --pod-network-cidr=10.244.0.0/16

# 配置 kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 安装网络插件（如 Calico）
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

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