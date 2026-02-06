### docker install openpose

[install openpose](./INSTALL.md)

```bash
apt-get update && apt-get install -y \
    python3 \
    libx11-6 \
    libglib2.0-0 \
    libegl1 \
    libegl1-mesa \
    libgles2 \
    libgles2-mesa \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    mesa-utils \
    mesa-common-dev \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxrandr2 \
    libxi6 \
    libxxf86vm1 \
    libxcursor1 \
    libxinerama1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    python3-venv \
    python3-dev \
    python3-pip \
    libfreetype6-dev \
    pkg-config \
    protobuf-compiler \
    libprotobuf-dev \
    libprotoc-dev \
    xvfb \
    wget \
    libgoogle-glog-dev \
    libopencv-dev \
    libboost1.74-dev \
    libboost-system1.74-dev \
    libboost-thread1.74-dev \
    libboost-filesystem1.74-dev \
    libboost-program-options1.74-dev \
    libboost-python1.74-dev \
    libhdf5-103 \
    libhdf5-cpp-103 \
    libhdf5-dev \
    libhdf5-openmpi-dev \
    libhdf5-serial-dev \
    swig \
    libatlas3-base \
    libatlas-base-dev \
    liblapack3 \
    liblapack-dev
    
apt-get update

# 清理旧的包缓存
apt-get clean
rm -rf /var/lib/apt/lists/*
apt-get update
apt-get install -y software-properties-common
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt-get update

# apt search cudnn
# apt search cuda-12-9 | grep cudnn
apt-get install -y \
    cudnn9-cuda-11-8 \
    libcudnn9-dev-cuda-11 \
    libcudnn9-headers-cuda-11
    
    
cmake .. \
    -DBUILD_PYTHON=ON \
    -DPYTHON_EXECUTABLE=$(python -c "import sys; print(sys.executable)") \
    -DPYTHON_LIBRARY=$(find /mnt/nvme2/develope/develope/code/py-project/smplify-xmc/.venv/ -name "libpython*.so" 2>/dev/null || find /usr -name "libpython*.so" 2>/dev/null | head -1) \
    -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DGPU_MODE=CUDA \
    -DCUDA_ARCH=Auto \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-12

make -j$(nproc)
```