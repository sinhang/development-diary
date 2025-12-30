### PROXY

### 当前 Shell 环境变量
```bash
env | grep -i proxy
# or
printenv | grep -i proxy
```

### 临时设置或修改代理
```bash
export http_proxy=http://127.0.0.1:1080
export https_proxy=http://127.0.0.1:1080
```