### INSTALL helm

1. [Install Helm](https://helm.sh/docs/intro/install/)
2. [website](https://helm.sh/)
3. [github](https://github.com/helm/helm)

```bash
# 创建目录
mkdir helm
cd helm
# 下载helm
wget https://get.helm.sh/helm-v4.0.0-linux-amd64.tar.gz

# 解压
tar -zxvf helm-v4.0.0-linux-amd64.tar.gz

# 移动文件
sudo mv linux-amd64/helm /usr/local/bin/helm

# 验证
helm version
```


### 指令
```bash
# 添加stable仓库
helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

# 添加bitnami仓库
helm repo add bitnami https://charts.bitnami.com/bitnami

# 列出仓库
helm repo list

# 更新仓库
helm repo update

# 搜索仓库
helm search repo stable
```