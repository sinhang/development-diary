### ubuntu install

1. [golang中文下载](https://studygolang.com/dl)
2. [docs](https://books.studygolang.com/gopl-zh/)

```bash
sudo apt-get install golang -y

# 源码安装

# 验证
go version
```

### 设置golang环境变量
```bash
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GO111MODULE=on
```