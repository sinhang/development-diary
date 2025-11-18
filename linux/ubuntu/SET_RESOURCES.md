### ubuntu 源设置

1. [阿里云源](https://developer.aliyun.com/mirror/ubuntu/)

### 新版 sources.list
```shell
cat /etc/apt/sources.list
# 输出
# Ubuntu sources have moved to /etc/apt/sources.list.d/ubuntu.sources

cat /etc/apt/sources.list.d/ubuntu.sources
# 输出
# Types: deb
# URIs: http://cn.archive.ubuntu.com/ubuntu/
# Suites: noble noble-updates noble-backports
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# Types: deb
# URIs: http://security.ubuntu.com/ubuntu/
# Suites: noble-security
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 新建 阿里云源 sources.list 文件
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/aliyun.sources

echo "Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg" | sudo tee /etc/apt/sources.list.d/aliyun.sources > /dev/null

# 备份 /etc/apt/sources.list.d/ubuntu.sources
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak

# 更新源
sudo apt update
```