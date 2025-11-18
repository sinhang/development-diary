### 容器里面使用 Comfyui

1. [nvidia docker tags](https://hub.docker.com/r/nvidia/cuda/tags)

```bash
sudo docker run --name comfyui -v /home:/home -p 8188:8188 -itd --gpus all --privileged -u root --entrypoint /bin/sh nvidia/cuda:13.0.0-cudnn-devel-ubuntu24.04
```

```bash
# 进入容器
sudo docker exec -it comfyui /bin/bash
```
[设置 ubuntu 源](../../linux/ubuntu/SET_RESOURCES.md)

```bash
apt install git curl -y
```