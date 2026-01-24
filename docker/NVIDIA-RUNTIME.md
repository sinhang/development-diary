```bash
sudo apt update
# 安装 nvidia-container-toolkit
sudo apt install -y nvidia-container-toolkit
# Docker 注册 nvidia runtime
sudo nvidia-ctk runtime configure --runtime=docker
```

### 查看 daemon.json 文件
```bash
cat /etc/docker/daemon.json
```
## daemon.json 文件
```json
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
```

### 重启Docker
```bash
sudo systemctl restart docker
```

## 验证
```bash
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```