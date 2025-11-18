### NVIDIA NVCC INSTALL

1. [NVIDIA NVCC INSTALL GUIDE](https://developer.nvidia.com/cuda-13-0-0-download-archive)
2. 设置环境变量

```shell
echo 'export PATH=/usr/local/cuda-13.0/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-13.0/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```