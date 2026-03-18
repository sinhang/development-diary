### CREATE OLLAMA MODEL

### sources Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled
[Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled](https://huggingface.co/Jackrong/Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled/tree/main)
[ollama](https://ollama.com/)


### 下载模型文件
```bash
mkdir Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled
cd Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled
# 下载 Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled 所有文件
ls
# chat_template.jinja                           model.safetensors-00003-of-00011.safetensors  model.safetensors-00008-of-00011.safetensors  processor_config.json
# config.json                                   model.safetensors-00004-of-00011.safetensors  model.safetensors-00009-of-00011.safetensors  README.md
# gitattributes                                 model.safetensors-00005-of-00011.safetensors  model.safetensors-00010-of-00011.safetensors  tokenizer_config.json
# model.safetensors-00001-of-00011.safetensors  model.safetensors-00006-of-00011.safetensors  model.safetensors-00011-of-00011.safetensors  tokenizer.json
# model.safetensors-00002-of-00011.safetensors  model.safetensors-00007-of-00011.safetensors  model.safetensors.index.json
```

### 将 safetensors 转成 ollama 支持的 GGUF 模型
```bash
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
pyenv local 3.10.12
python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
uv pip install -r requirements.txt
# 版本兼容问题
pip uninstall -y transformers tokenizers
pip install -U transformers>=4.57.1 tokenizers>=0.22.0 sentencepiece tiktoken

# 模型转换, 磁盘空间至少空闲 50 GB 以上
python convert_hf_to_gguf.py ../Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled --outfile qwen35-27b-f16.gguf --outtype f16

# 编译 ollama
cmake -B build -DGGML_CUDA=ON
cmake --build build -j

# 模型量化，如果需要下面三种量化方式，磁盘空间至少空闲 130 GB 以上
./build/bin/llama-quantize qwen35-27b-f16.gguf qwen35-27b-q4_k_m.gguf Q4_K_M
./build/bin/llama-quantize qwen35-27b-f16.gguf qwen35-27b-q5_k_m.gguf Q5_K_M
./build/bin/llama-quantize qwen35-27b-f16.gguf qwen35-27b-q8_0.gguf Q8_0

cp qwen35-27b-q5_k_m.gguf /models/qwen35-27b-cluade-q5_k_m/
```

### ollama 部署模型

### /models/qwen35-27b-cluade-q5_k_m/Modelfile 写入下面内容
```
#Modelfile
FROM /models/qwen35-27b-cluade-q5_k_m/qwen35-27b-q5_k_m.gguf

RENDERER qwen3.5
PARSER qwen3.5

TEMPLATE """{{ .Prompt }}"""

PARAMETER temperature 1
PARAMETER top_p 0.95
PARAMETER top_k 20
PARAMETER presence_penalty 1.5

PARAMETER num_ctx 262144 # 上下文长度

PARAMETER repeat_penalty 1.1
PARAMETER num_batch 256 
PARAMETER num_gpu 99        


SYSTEM """You are Qwen, created by Alibaba Cloud. You are a helpful assistant."""
```

```bash
cd qwen35-27b-q5_k_m.gguf /models/qwen35-27b-cluade-q5_k_m/
pwd
/models/qwen35-27b-cluade-q5_k_m
ls
# Modelfile  qwen35-27b-q5_k_m.gguf
# 创建模型
ollama create qwen3.5:27b-q5_K_M-claude -f Modelfile
```

### 运行模型
```bash
ollama run qwen3.5:27b-q5_K_M-claude
```

### 爆显存问题
```bash
# https://docs.ollama.com/faq#how-does-ollama-load-models-on-multiple-gpus
export OLLAMA_KV_CACHE_TYPE=q8_0
ollama run qwen3.5:27b-q5_K_M-claude

>>> 你好
Thinking...
用户用中文打招呼“你好”，这是很简单的问候。
我是Qwen，阿里巴巴云创建的AI助手。
我应该友好地回应用户的问候，并提供帮助。
...done thinking.

你好！👋

很高兴见到你！我是Qwen，阿里巴巴云创建的AI助手。

有什么我可以帮助你的吗？比如：
- 回答问题
- 写作或编辑文本
- 数学计算
- 编程帮助
- 逻辑推理
- 或其他任何问题

请随时告诉我你需要什么帮助！😊

>>> /bye
```