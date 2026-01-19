### install openpose

[openpose](https://github.com/CMU-Perceptual-Computing-Lab/openpose)
[install protobuf](../../linux/ubuntu/soft/protobuf.md)

### install openpose
```shell
git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git
cd openpose
mkdir build && cd build
cmake ..
make -j`nproc`
```

### donwload models
```shell
cd models
./getModels.sh 
```

### openpose 运行
```shell
./build/examples/openpose/openpose.bin --video ../examples/media/video.avi --write_json ./output/

./build/examples/openpose/openpose.bin --image_dir /mnt/hdd/develope/3D --write_json ./json_results --face --hand

./build/examples/openpose/openpose.bin --image_dir /mnt/hdd/develope/3D --write_json ./json_results --display 0 --render_pose 0 --face --hand
```

### clean
```shell
rm -rf build/ CMakeFiles/ CMakeCache.txt cmake_install.cmake Makefile
```

# OpenPose 命令行参数详解

## 系统参数

### gflags 参数
- **`-flagfile`**：从文件加载标志
- **`-fromenv`**：从环境变量设置标志（使用 `export FLAGS_flag1=value`）
- **`-tryfromenv`**：如果存在则从环境变量设置标志
- **`-undefok`**：允许在命令行指定程序未定义的标志名列表（逗号分隔）

### 自动补全参数
- **`-tab_completion_columns`**：自动补全输出列数，默认 80
- **`-tab_completion_word`**：如果非空，将劫持进程并尝试进行 bash 风格的命令行标志自动补全

### 帮助和版本
- **`-help`**：显示所有标志的帮助
- **`-helpfull`**：显示所有标志的帮助（与 -help 相同）
- **`-helpmatch`**：显示包含指定子串的模块帮助
- **`-helpon`**：显示命名模块的帮助
- **`-helppackage`**：显示主包中所有模块的帮助
- **`-helpshort`**：仅显示主模块的帮助
- **`-helpxml`**：生成 XML 版本的帮助
- **`-version`**：显示版本和构建信息并退出

### 日志参数
- **`-alsologtoemail`**：日志消息同时发送到这些电子邮件地址
- **`-alsologtostderr`**：日志消息同时发送到 stderr
- **`-colorlogtostderr`**：彩色日志输出到 stderr
- **`-colorlogtostdout`**：彩色日志输出到 stdout
- **`-drop_log_memory`**：丢弃内存中的日志缓冲区
- **`-log_backtrace_at`**：在指定文件:行号记录回溯
- **`-log_dir`**：日志文件写入此目录
- **`-log_link`**：在此目录放置日志文件的附加链接
- **`-log_prefix`**：在每行日志开始添加前缀
- **`-log_utc_time`**：使用 UTC 时间记录
- **`-log_year_in_prefix`**：在日志前缀中包含年份
- **`-logbuflevel`**：缓冲此级别或更低级别的日志消息
- **`-logbufsecs`**：最多缓冲日志消息若干秒
- **`-logcleansecs`**：每隔若干秒清理过期日志
- **`-logemaillevel`**：邮件发送此级别或更高级别的日志消息
- **`-logfile_mode`**：日志文件模式/权限
- **`-logmailer`**：用于发送日志邮件的邮件程序
- **`-logtostderr`**：日志消息发送到 stderr 而不是日志文件
- **`-logtostdout`**：日志消息发送到 stdout 而不是日志文件
- **`-max_log_size`**：近似最大日志文件大小（MB）
- **`-minloglevel`**：低于此级别的消息不会记录
- **`-stderrthreshold`**：等于或高于此级别的日志消息复制到 stderr
- **`-stop_logging_if_full_disk`**：磁盘满时停止尝试记录到磁盘
- **`-timestamp_in_logfile_name`**：在日志文件名末尾添加时间戳

## OpenPose 特定参数

### 3D 重建参数
- **`-3d`**：运行 OpenPose 3D 重建演示
- **`-3d_min_views`**：重建每个关键点所需的最小视图数
- **`-3d_views`**：与 `--image_dir` 或 `--video` 互补的选项

### 渲染参数
- **`-alpha_heatmap`**：热图和原始帧之间的混合因子（范围 0-1）
- **`-alpha_pose`**：人体部位渲染的混合因子（范围 0-1）

### 检测参数
- **`-body`**：选择 0 禁用人体关键点检测，1（默认）用于人体关键点估计，2 禁用内部网络但运行贪婪关联解析算法
- **`-face`**：启用面部关键点检测
- **`-hand`**：启用手部关键点检测

### 摄像头参数
- **`-camera`**：cv::VideoCapture 的摄像头索引
- **`-camera_parameter_path`**：摄像头参数所在的文件夹
- **`-camera_resolution`**：设置摄像头分辨率
- **`-flir_camera`**：是否使用 FLIR（Point-Grey）立体摄像头
- **`-flir_camera_index`**：FLIR 摄像头索引

### 输入源参数
- **`-image_dir`**：处理图像目录
- **`-video`**：使用视频文件而不是摄像头
- **`-ip_camera`**：IP 摄像头 URL

### 模型参数
- **`-model_folder`**：模型存放的文件夹路径
- **`-model_pose`**：使用的模型（BODY_25、COCO、MPI 等）
- **`-caffemodel_path`**：caffemodel 文件路径
- **`-prototxt_path`**：prototxt 文件路径

### 网络参数
- **`-net_resolution`**：网络输入分辨率（默认 -1x368）
- **`-net_resolution_dynamic`**：动态网络分辨率
- **`-scale_number`**：平均缩放数量
- **`-scale_gap`**：缩放间隔
- **`-upsampling_ratio`**：上采样比率

### 渲染参数
- **`-render_pose`**：渲染设置（0 不渲染，1 CPU 渲染，2 GPU 渲染）
- **`-render_threshold`**：仅渲染置信度分数高于此阈值的关键点
- **`-disable_blending`**：在黑色背景上渲染结果
- **`-part_to_show`**：要可视化的预测通道

### 性能参数
- **`-num_gpu`**：使用的 GPU 数量
- **`-num_gpu_start`**：GPU 设备起始编号
- **`-fps_max`**：最大处理帧率
- **`-disable_multi_thread`**：略微降低帧率以大幅减少延迟
- **`-process_real_time`**：保持原始源帧率

### 输出参数
- **`-write_json`**：写入 OpenPose 输出的 JSON 格式目录
- **`-write_images`**：写入渲染帧的目录
- **`-write_images_format`**：写入图像的文件扩展名和格式
- **`-write_video`**：写入渲染帧的视频文件路径
- **`-write_video_fps`**：录制视频的帧率
- **`-output_resolution`**：图像分辨率（显示和输出）

### 阈值和过滤参数
- **`-number_people_max`**：限制检测的最大人数
- **`-maximize_positives`**：减少接受人员候选的阈值
- **`-part_candidates`**：填充姿态候选人数组
- **`-keypoint_scale`**：最终姿态数据数组中 (x,y) 坐标的缩放

### 其他参数
- **`-display`**：显示模式（-1 自动选择，0 无显示，2 2D 显示，3 3D 显示）
- **`-frame_first`**：从所需帧号开始
- **`-frame_last`**：在所需帧号结束
- **`-frame_step`**：处理帧之间的步长
- **`-frame_flip`**：翻转/镜像每帧
- **`-frame_rotate`**：旋转每帧
- **`-logging_level`**：日志级别（0-255）
- **`-no_gui_verbose`**：不在输出图像上写文本
- **`-cli_verbose`**：命令行详细程度

## 实际应用示例

```bash
# 基本人体姿态检测
./build/examples/openpose/openpose.bin --model_pose BODY_25 --net_resolution 656x368

# 处理图像目录
./build/examples/openpose/openpose.bin --image_dir examples/media/ --write_json output/

# 视频处理
./build/examples/openpose/openpose.bin --video examples/media/video.avi --write_video output/result.avi

# 同时检测人脸和手
./build/examples/openpose/openpose.bin --face --hand --render_pose 2

# GPU 设置
./build/examples/openpose/openpose.bin --num_gpu 1 --render_pose 2

# 调整检测阈值
./build/examples/openpose/openpose.bin --render_threshold 0.5
```
