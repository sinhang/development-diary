### ubuntu install

1. [golang中文下载](https://studygolang.com/dl)
2. [docs](https://books.studygolang.com/gopl-zh/)

```bash
sudo apt-get install golang -y

# 源码安装

# 验证
go version
```

### 安装包安装
```bash
mkdir ~/go
cd ~/go
wget https://studygolang.com/dl/golang/go1.25.0.linux-amd64.tar.gz
tar -zxvf go1.25.0.linux-amd64.tar.gz
echo "export PATH=$PATH:/home/{username}/go/bin" >> ~/.bashrc
source ~/.bashrc

go version
```

### 设置golang环境变量
```bash
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GO111MODULE=on
```