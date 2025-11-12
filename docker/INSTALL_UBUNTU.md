### docker 站点资源
1. [docker 官网](https://docker.com)
2. [docker 镜像](https://hub.docker.com)
3. [docker 官方文档](https://docs.docker.com)
4. [Ubuntu install](https://docs.docker.com/engine/install/ubuntu/)

### Docker install

```shell
# ubuntu 24.04 install shell
# /home/<username>/docker/install.sh

echo "for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin" > /home/<username>/docker/install.sh

sudo chmod +x /home/<username>/docker/install.sh
sudo ./install.sh
```

### 查看docker状态
```shell
sudo systemctl status docker
```

### 设置docker镜像
```shell
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://mirror.ccs.tencentyun.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.nju.edu.cn",
    "https://docker.m.daocloud.io"
  ]
}
EOF
```

### 启动docker
```shell
sudo systemctl start docker
```