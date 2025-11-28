### INSTALL ARGOCD

1. [website](https://argo-cd.readthedocs.io/en/stable/)
2. [github](https://github.com/argoproj/argo-cd)
3. [docs](https://argo-cd.readthedocs.io/en/stable/getting_started/)
4. 需要先安装好 kubernetes [k8s](../INSTALL.md)


### INSTALL
```bash
# 创建目录
mkdir argocd
# 进入目录
cd argocd/

# 下载文件
wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 创建 argocd 命名空间
kubectl create namespace argocd

# 安装
kubectl apply -n argocd -f install.yaml

# 查看 pod
kubectl get pods -n argocd -o wine
```

# 安装 argocd-linux-amd64
```bash
wget https://github.com/argoproj/argo-cd/releases/download/v3.2.0/argocd-linux-amd64

# 移动文件
mv argocd-linux-amd64 /usr/local/bin/argocd

# 修改权限
chmod +x /usr/local/bin/argocd

# login
argocd login --core

# 设置 kubectl 上下文
kubectl config set-context --current --namespace=argocd
```


### 开放访问
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# kubectl get svc argocd-server -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'

kubectl get svc argocd-server -n argocd
# 输出
# NAME            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
# argocd-server   LoadBalancer   10.102.29.103   <pending>     80:30654/TCP,443:31855/TCP   81m

# 访问
# http://127.0.0.1:30654 / https://127.0.0.1:31855
# https://192.168.1.27:30654/applications
```

### 默认账号密码
```
账号： `admin`
```
### 获取默认密码
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
````

### 命令行登录
```bash
argocd login localhost:30654 --username admin --password "GOxmbPs9MoCNdtxC" --insecure
# 登录成功显示
# 'admin:login' logged in successfully
# Context 'localhost:30654' updated

# 获取集群列表
argocd cluster list

# 获取应用列表
argocd app list

# 查看应用详情
argocd app get app-name

# 删除应用
argocd app delete app-name

# 获取项目列表
argocd proj list

# 获取仓库列表
argocd repo list
```

### 创建应用
```bash
argocd app create simple-guestbook \
  --repo https://gitee.com/network_interruption_later/argocd-example-apps \
  --path guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated
```


### 测试镜像拉取失败
```bash
docker pull gcr.io/google-samples/gb-frontend:v5
```