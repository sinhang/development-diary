### CUDNN INSTALL

1. [cudnn install guide](https://developer.nvidia.com/cudnn-downloads)
2. 设置环境变量

```shell
echo 'export CUDNN_INCLUDE_DIR=/usr/local/cuda-13.0/include' >> ~/.bashrc
echo 'export CUDNN_LIB_DIR=/usr/local/cuda-13.0/lib64' >> ~/.bashrc
source ~/.bashrc
```