### INSTALL OpenPose

1. [github](https://github.com/CMU-Perceptual-Computing-Lab/openpose)
2. [install docs](https://github.com/CMU-Perceptual-Computing-Lab/openpose/blob/master/doc/installation/0_index.md#compiling-and-running-openpose-from-source)
3. [install cuda](../cuda/CUDA.md)


### download repo
```bash
git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git
cd openpose
git submodule update --init --recursive --remote
```

### 安装依赖
```bash
sudo apt install -y \
    libgflags-dev \
    libgoogle-glog-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libhdf5-serial-dev \
    libatlas-base-dev \
    libboost-all-dev \
    libopencv-dev
```

### 下载模型
```bash
cd models
# 如果太慢可以复制URL到浏览器下载
./getModels.sh
```

### 编译
```bash
mkdir build
cd build
# CPU版本
cmake .. -DBUILD_PYTHON=ON -DUSE_CUDA=OFF

# GPU版本
cmake .. -DBUILD_PYTHON=ON -DUSE_CUDA=ON

make -j$(nproc)

sudo make install

cd ../
./build/examples/openpose/openpose.bin --image_dir /mnt/nvme2/develope/develope/code/py-project/smplify-x/data/images/ --display 0 --write_images output/ --write_json output_json/ --hand --face --model_pose BODY_25
```