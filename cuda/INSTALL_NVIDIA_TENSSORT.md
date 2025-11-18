### INSTALL NVIDIA TENSORRT

1. [NVIDIA TENSORRT DOWNLOAD](https://developer.nvidia.com/tensorrt)
2. [NVIDIA TENSORRT INSTALL GUIDE](https://docs.nvidia.com/deeplearning/tensorrt/latest/installing-tensorrt/installing.html)
3. 设置环境变量

需要 nvidia 账号

```bash
echo 'export PATH=/usr/src/tensorrt/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LIBRARY_PATH' >> ~/.bashrc

echo 'export CUDA_HOME=/usr/local/cuda-12.4' >> ~/.bashrc
echo 'export TENSORRT_HOME=/usr/src/tensorrt' >> ~/.bashrc

source ~/.bashrc
```