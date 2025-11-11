### 安装 ComfyUI
1. 进入 [ComfyUI](https://github.com/comfyanonymous/ComfyUI) 仓库
2. 点击 `Code` 按钮，选择 `Download ZIP` 或者 `Code` 按钮下方的 `Clone` 按钮，选择 `HTTPS` 或 `SSH`
3. 解压下载的 ZIP 文件 或者 clone

```shell
cd /home/<username>/ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git
pyenv local <python_version>
python -m venv .venv
source venv/bin/activate
pip install -r requirements.txt
```

### 安装 WebUI (ComfyUI Manager)
1. 进入 [ComfyUI Manager](https://github.com/Comfy-Org/ComfyUI-Manager) 仓库
2. 点击 `Code` 按钮，选择 `Download ZIP` 或者 `Code` 按钮下方的 `Clone` 按钮，选择 `HTTPS` 或 `SSH`
3. 解压下载的 ZIP 文件 或者 clone
4. 进入到 `ComfyUI/custom_nodes` 目录
5. clone `ComfyUI-Manager`
6. 安装依赖

```shell
cd /home/<username>/ComfyUI/custom_nodes
git clone https://github.com/Comfy-Org/ComfyUI-Manager.git
pip install -r requirements.txt
```

### 启动 ComfyUI
1. 进入 `ComfyUI` 目录
2. 运行 `python main.py`
3. 访问 `http://localhost:8188`

```shell
cd /home/<username>/ComfyUI
python main.py
```

### 查看 ComfyUI 启动参数
1. 进入 `ComfyUI` 目录
2. 运行 `python main.py --help`

```shell
cd /home/<username>/ComfyUI/
python main.py --help
```

### 启动参数
- `--listen`: 指定要监听的 IP 地址（默认值：127.0.0.1）。您可以指定一个 IP 地址列表，并用逗号分隔，例如：127.2.2.2,127.3.3.3。如果未提供参数，则默认为 0.0.0.0,::（监听所有 IPv4 和 IPv6 地址）。
- `--port`: 设置监听端口。如：8188
- `--tls-keyfile`: TLS(SSL)密钥文件的路径。启用TLS后需要通过 https:// 访问。必须要启用 --tls-certfile 才能正常工作。
- `--tls-certfile`: TLS(SSL)证书文件的路径。启用TLS后需要通过 https:// 访问。需要 --tls-keyfile 参数才能正常工作。
- `--enable-cors-header`: 启用 CORS（跨域资源共享），可选择指定来源，或默认允许所有来源（使用默认值“*”）。
- `--max-upload-size`: 设置最大上传文件大小（以 MB 为单位）。
- `--base-directory`: 设置 ComfyUI 模型、自定义节点、输入、输出、临时和用户目录的根目录。
- `--extra-model-paths-config`: 加载一个或多个 extra_model_paths.yaml 文件。
- `--output-directory`: 设置 ComfyUI 输出目录。此参数会覆盖 --base-directory 参数。
- `--temp-directory`: 设置 ComfyUI 临时目录（默认位于 ComfyUI 目录中）。此参数会覆盖 --base-directory 参数。
- `--input-directory`: 设置 ComfyUI 输入目录。此设置会覆盖 --base-directory 的值。
- `--auto-launch`: 自动在默认浏览器中启动 ComfyUI。
- `--disable-auto-launch`: 禁用浏览器自动启动。
- `--cuda-device`: 设置此实例将使用的 CUDA 设备的 ID。所有其他设备将不可见。第一张显卡为 0。
- `--default-device`: 设置默认设备的 ID，所有其他设备将保持可见。
- `--cuda-malloc`: 启用 cudaMallocAsync（Torch 2.0 及更高版本默认启用）。
- `--disable-cuda-malloc`: 禁用 cudaMallocAsync。
- `--force-fp32`: 强制使用 fp32（如果这能改善 GPU 性能，请报告）。
- `--force-fp16`: 强制使用 FP16
- `--fp32-unet`: 以 fp32 精度运行扩散模型。
- `--fp64-unet`: 以 fp64 精度运行扩散模型。
- `--bf16-unet`: 以 bf16 精度运行扩散模型。
- `--fp16-unet`: 以 fp16 精度运行扩散模型。
- `--fp8_e4m3fn-unet`: 将 unet 权重存储到 fp8_e4m3fn 中。
- `--fp8_e5m2-unet`: 将 unet 权重存储到 fp8_e5m2 中。
- `--fp8_e8m0fnu-unet`: 将 unet 权重存储到 fp8_e8m0fnu 中。
- `--fp16-vae`: 以 fp16 精度运行 VAE，可能会导致图像变黑。
- `--fp32-vae`: 以全精度 fp32 精度运行 VAE。
- `--bf16-vae`: 以 bf16 精度运行 VAE。
- `--cpu-vae`: 在 CPU 上运行 VAE。
- `--fp8_e4m3fn-text-enc`: 将文本编码器权重存储为 fp8（e4m3fn 变体）。
- `--fp8_e5m2-text-enc`: 将文本编码器权重存储为 fp8（e5m2 变体）。
- `--fp16-text-enc`: 将文本编码器权重存储为 fp16。
- `--fp32-text-enc`: 将文本编码器权重存储为 fp32。
- `--bf16-text-enc`: 将文本编码器权重存储为 bf16。
- `--force-channels-last`: 在推理模型时强制使用通道后置格式。
- `--directml`: `[DIRECTML_DEVICE]` 使用 torch-directml。
- `--oneapi-device-selector`: 设置此实例将使用的 oneAPI 设备。
- `--disable-ipex-optimize`: 禁用使用 Intel PyTorch 扩展加载模型时默认的 ipex.optimize 优化。
- `--supports-fp8-compute`: ComfyUI 将模拟设备支持 fp8 计算的情况。
- `--preview-method`: `[none,auto,latent2rgb,taesd]` 采样器节点的默认预览方法。
- `--preview-size`: `PREVIEW_SIZE` 设置采样器节点的最大预览大小。
- `--cache-classic`: 使用旧式（激进）缓存。
- `--cache-lru`: 使用 LRU 缓存，最多缓存 N 个节点的结果。可能会占用更多 RAM/VRAM。
- `--cache-none`: 减少 RAM/VRAM 使用，但每次运行都会执行所有节点。
- `--cache-ram`: `[CACHE_RAM]` 使用 RAM 压力缓存，并指定缓存余量阈值。如果可用内存低于阈值，缓存将移除大型项目以释放​​内存。默认值为 4GB
- `--use-split-cross-attention`: 使用分裂交叉注意力优化。使用 xformers 时忽略此参数。
- `--use-quad-cross-attention`: 使用亚二次交叉注意力优化。使用 xformers 时忽略此参数。
- `--use-pytorch-cross-attention`: 使用 PyTorch 2.0 的新交叉注意力函数。
- `--use-sage-attention`: 启用 Sage Attention。
- `--use-flash-attention`: 启用 Flash Attention。
- `--disable-xformers`: 禁用 Xformers。
- `--force-upcast-attention`: 强制启用 Attention 向上投射，如果修复了黑屏问题，请报告。
- `--dont-upcast-attention`: 禁用所有 Attention 向上投射。除了调试之外，应该不需要此操作。
- `--gpu-only`: 将所有数据（文本编码器/CLIP 模型等）存储并运行在 GPU 上。
- `--highvram`: 默认情况下，模型在使用后会卸载到 CPU 内存。此选项会将它们保留在 GPU 内存中。
- `--normalvram`: 如果 lowvram 自动启用，则用于强制使用正常显存。
- `--lowvram`: 将 Unet 分割成多个部分以减少显存使用。
- `--novram`: 当 lowvram 不足时使用。
- `--cpu`: 使用 CPU 处理所有任务（速度较慢）。
- `--reserve-vram`: `RESERVE_VRAM` 设置要为操作系统或其他软件预留的显存大小（以 GB 为单位）。默认情况下，会预留一定量的显存，具体大小取决于您的操作系统。
- `--async-offload`: 使用异步权重卸载。
- `--force-non-blocking`: 强制 ComfyUI 对所有适用的张量使用非阻塞操作。这可能会提高某些非 Nvidia 系统上的性能，但可能会导致某些工作流程出现问题。
- `--default-hashing-function`: `{md5,sha1,sha256,sha512}` 允许您选择用于重复文件名/内容比较的哈希函数。默认值为 sha256。
- `--disable-smart-memory`: 强制 ComfyUI 在条件允许的情况下，积极地将模型卸载到普通内存，而不是将其保留在显存中。
- `--deterministic`: 使 PyTorch 在条件允许的情况下使用速度较慢的确定性算法。请注意，这可能无法在所有情况下都使图像具有确定性。
- `--fast`: `[FAST ...]` 启用一些未经测试且可能降低质量的优化。不带任何参数的 --fast 将启用所有优化。您可以传递一个特定优化列表，以便仅启用特定优化。当前有效的优化：`fp16_accumulation fp8_matrix_mult cublas_ops autotune pinned_memory`
- `--mmap-torch-files`: 加载 ckpt/pt 文件时使用 mmap。
- `--disable-mmap`: 加载 safetensors 时不使用 mmap。
- `--dont-print-server`: 不打印服务器输出。
- `--quick-test-for-ci`: CI 快速测试。
- `--windows-standalone-build`: Windows 独立构建：启用大多数使用 Windows 独立构建的用户可能会喜欢的便捷功能（例如启动时自动打开页面）。
- `--disable-metadata`: 禁用将提示元数据保存到文件中。
- `--disable-all-custom-nodes`: 禁用加载所有自定义节点。
- `--whitelist-custom-nodes`: `WHITELIST_CUSTOM_NODES [WHITELIST_CUSTOM_NODES ...]`
指定即使启用了 --disable-all-custom-nodes 也要加载的自定义节点文件夹。
- `--disable-api-nodes`: 禁用加载所有 API 节点。
- `--multi-user`: 启用按用户存储。
- `--verbose`: `[{DEBUG,INFO,WARNING,ERROR,CRITICAL}]` 设置日志级别。
- `--log-stdout`: 将正常进程输出发送到标准输出 (stdout) 而不是标准错误输出 (stderr)（默认）。
- `--front-end-version`: `FRONT_END_VERSION` 指定要使用的前端版本。此命令需要互联网连接才能查询和下载可用的前端实现（来自 GitHub 发布）。版本字符串的格式应为：`[repoOwner]/[repoName]@[version]` 其中 version 可以是以下值之一：“latest” 或有效的版本号（例如“1.0.0”）。
- `--front-end-root`: `FRONT_END_ROOT` 前端所在的本地文件系统路径。此参数会覆盖 `--front-end-version` 的值。
- `--user-directory`: 使用绝对路径设置 ComfyUI 用户目录。此参数会覆盖 `--base-directory` 的值。
- `--enable-compress-response-body`: 启用压缩响应体。
- `--comfy-api-base`: `COMFY_API_BASE` 设置 ComfyUI API 的基本 URL。（默认值：https://api.comfy.org）
- `--database-url`: `DATABASE_URL` 指定数据库 URL，例如，对于内存数据库，可以使用 'sqlite:///:memory:'。