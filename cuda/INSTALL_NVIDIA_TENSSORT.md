### INSTALL NVIDIA TENSORRT

1. [NVIDIA TENSORRT DOWNLOAD](https://developer.nvidia.com/tensorrt)
2. [NVIDIA TENSORRT INSTALL GUIDE](https://docs.nvidia.com/deeplearning/tensorrt/latest/installing-tensorrt/installing.html)
3. 设置环境变量

需要 nvidia 账号

```bash
wget https://developer.download.nvidia.com/compute/tensorrt/10.14.1/local_installers/nv-tensorrt-local-repo-ubuntu2404-10.14.1-cuda-13.0_1.0-1_amd64.deb
sudo dpkg -i nv-tensorrt-local-repo-ubuntu2404-10.14.1-cuda-13.0_1.0-1_amd64.deb

# sudo cp /var/nv-tensorrt-local-repo-ubuntu2404-10.14.1-cuda-13.0/nv-tensorrt-local-D12DA6BC-keyring.gpg /usr/share/keyrings/ 	# 根据上条命令的提示执行

sudo apt-get update
sudo apt install tensorrt
sudo apt install python3-libnvinfer-dev
dpkg -l | grep tensorrt
```

```bash
echo 'export PATH=/usr/src/tensorrt/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LIBRARY_PATH' >> ~/.bashrc

echo 'export CUDA_HOME=/usr/local/cuda-13.0' >> ~/.bashrc
echo 'export TENSORRT_HOME=/usr/src/tensorrt' >> ~/.bashrc

source ~/.bashrc
```