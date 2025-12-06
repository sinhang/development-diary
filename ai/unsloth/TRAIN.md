### unsloth train

1. [github](https://github.com/unslothai/unsloth)
2. [website](https://unsloth.ai)
3. [models](https://docs.unsloth.ai/get-started/all-our-models)
4. [教程](https://blog.csdn.net/u012856866/article/details/140955316)
5. [知乎教程](https://zhuanlan.zhihu.com/p/698608439)

### 安装依赖
```bash
# 安装torch
pip install torch==2.7.1+cu128 torchvision==0.22.1+cu128 torchaudio==2.7.1+cu128 --index-url https://download.pytorch.org/whl/cu128
# 查询可以是包哪些版本
pip index versions torchao
pip install torchao==0.12.0
pip install xformers==0.0.31.post1
pip install unsloth tensorboard
```

### 准备数据 
```
customer_service_data.jsonl 内容如下：
```
```jsonl
{"instruction": "用户反馈商品损坏怎么办？", "output": "1. 表达歉意... 2. 询问订单号... 3. 提供解决方案..."}
{"instruction": "用户想退货但已超7天", "output": "根据政策，超过7天无理由退货期...但我们可以..."}
```

### 训练代码
```python
# train.py
from unsloth import FastLanguageModel
import torch
from peft import LoraConfig
from datasets import load_dataset
from trl import SFTTrainer
from transformers import TrainingArguments

# 1. 加载模型和分词器（4-bit量化节省显存） https://huggingface.co/unsloth/llama-3-8b-Instruct-bnb-4bit
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name = "unsloth/llama-3-8b-bnb-4bit",  # 可换其他模型
    max_seq_length = 2048,
    dtype = torch.float16,
    load_in_4bit = True,  # 4位量化
)

# 2. 添加LoRA适配器（核心步骤）
model = FastLanguageModel.get_peft_model(
    model,
    r = 16,           # LoRA秩，越大能力越强但参数越多（常用8-64）
    target_modules = ["q_proj", "k_proj", "v_proj", "o_proj"], # 要微调的层
    lora_alpha = 16,
    lora_dropout = 0,
    bias = "none",
    use_gradient_checkpointing = True,
)

# 3. 准备数据
dataset = load_dataset("json", data_files="customer_service_data.jsonl", split="train")

def formatting_func(example) -> list[str]:
    # 检查必要字段是否存在
    if 'instruction' not in example or 'output' not in example:
        raise ValueError("Missing required fields in example")
    return [f"""你是一个专业的客服助手。请根据以下用户问题，提供专业、友好的回复。

用户问题：{example['instruction']}

回复：{example['output']}"""]


# 4. 训练参数设置
training_args = TrainingArguments(
    output_dir="./results",
    overwrite_output_dir=True,
    num_train_epochs=3,
    per_device_train_batch_size=4,
    per_device_eval_batch_size=4,

    learning_rate=2e-4,
    weight_decay=0.01,
    warmup_ratio=0.03,

    lr_scheduler_type="cosine",

    eval_strategy="steps",
    eval_steps=500,
    save_strategy="steps",
    save_steps=500,
    save_total_limit=2,

    logging_strategy="steps",
    logging_steps=100,
    report_to=["tensorboard"],  # or "wandb"

    fp16=True,  # 混合精度训练
    gradient_accumulation_steps=4,  # 模拟更大batch size
    gradient_checkpointing=True,  # 显存优化

    load_best_model_at_end=True,
    metric_for_best_model="eval_loss",
    greater_is_better=False,
)

lora_config = LoraConfig(
    # ========== 基础必设参数 ==========
    r=16,  # LoRA秩（最重要！）
    lora_alpha=32,  # 缩放系数
    target_modules=["q_proj", "v_proj"],  # 目标模块

    # ========== 可选优化参数 ==========
    lora_dropout=0.1,  # Dropout率
    bias="none",  # 偏置处理
    task_type="CAUSAL_LM",  # 任务类型

    # ========== 高级参数 ==========
    modules_to_save=["embed_tokens", "lm_head"],  # 额外训练层
    layers_to_transform=None,  # 指定层范围
    layers_pattern=None,  # 层匹配模式
    rank_pattern={},  # 不同层不同秩
    alpha_pattern={},  # 不同层不同alpha
    fan_in_fan_out=False,  # 矩阵方向

    # ========== 特殊参数 ==========
    use_dora=False,  # DoRA增强
    use_rslora=False,  # Rank-Stabilized LoRA
    init_lora_weights="gaussian",  # 权重初始化
)

trainer = SFTTrainer(
    model=model,
    args=training_args,  # ← 这里传入所有训练参数！
    train_dataset=dataset,
    eval_dataset=dataset,
    processing_class=tokenizer,
    formatting_func=formatting_func,
    peft_config=lora_config,  # 如果是LoRA微调
)


if __name__ == '__main__':
    # 5. 开始训练！
    trainer.train()

    # 6. 保存你的专属模型
    model.save_pretrained("my_customer_service_lora")
    tokenizer.save_pretrained("my_customer_service_lora")
```

### 运行
```bash
# 运行的过程中会自动下载模型，请耐心等待
python train.py
```

### 训练输出
```
🦥 Unsloth: Will patch your computer to enable 2x faster free finetuning.
🦥 Unsloth Zoo will now patch everything to make training faster!
==((====))==  Unsloth 2025.11.6: Fast Llama patching. Transformers: 4.57.2.
   \\   /|    NVIDIA GeForce RTX 4060 Ti. Num GPUs = 1. Max memory: 15.572 GB. Platform: Linux.
O^O/ \_/ \    Torch: 2.7.1+cu128. CUDA: 8.9. CUDA Toolkit: 12.8. Triton: 3.3.1
\        /    Bfloat16 = TRUE. FA [Xformers = 0.0.31.post1. FA2 = False]
 "-____-"     Free license: http://github.com/unslothai/unsloth
Unsloth: Fast downloading is enabled - ignore downloading bars which are red colored!
Not an error, but Unsloth cannot patch MLP layers with our manual autograd engine since either LoRA adapters
are not enabled or a bias term (like in Qwen) is used.
Unsloth 2025.11.6 patched 32 layers with 32 QKV layers, 32 O layers and 0 MLP layers.
Generating train split: 2 examples [00:00, 444.10 examples/s]
num_proc must be <= 2. Reducing num_proc to 2 for dataset of size 2.
[datasets.arrow_dataset|WARNING]num_proc must be <= 2. Reducing num_proc to 2 for dataset of size 2.
Unsloth: Tokenizing ["text"] (num_proc=2): 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 2/2 [00:02<00:00,  1.07s/ examples]
num_proc must be <= 2. Reducing num_proc to 2 for dataset of size 2.
[datasets.arrow_dataset|WARNING]num_proc must be <= 2. Reducing num_proc to 2 for dataset of size 2.
The model is already on multiple devices. Skipping the move to device specified in `args`.
==((====))==  Unsloth - 2x faster free finetuning | Num GPUs used = 1
   \\   /|    Num examples = 2 | Num Epochs = 3 | Total steps = 3
O^O/ \_/ \    Batch size per device = 4 | Gradient accumulation steps = 4
\        /    Data Parallel GPUs = 1 | Total batch size (4 x 4 x 1) = 16
 "-____-"     Trainable parameters = 13,631,488 of 8,043,892,736 (0.17% trained)
{'train_runtime': 23.7105, 'train_samples_per_second': 0.253, 'train_steps_per_second': 0.127, 'train_loss': 3.168451944986979, 'epoch': 3.0}                                                                                                           
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 3/3 [00:23<00:00,  7.90s/it]
```

### 结果
```bash
tree ./results/
./results/
├── checkpoint-3
│   ├── adapter_config.json
│   ├── adapter_model.safetensors
│   ├── optimizer.pt
│   ├── README.md
│   ├── rng_state.pth
│   ├── scaler.pt
│   ├── scheduler.pt
│   ├── special_tokens_map.json
│   ├── tokenizer_config.json
│   ├── tokenizer.json
│   ├── trainer_state.json
│   └── training_args.bin
├── README.md
└── runs
    ├── Dec05_17-43-30_mercury-X99
    │   └── events.out.tfevents.1764927813.mercury-X99.2241841.0
    ├── Dec05_17-48-47_mercury-X99
    │   └── events.out.tfevents.1764928133.mercury-X99.2262412.0
    ├── Dec05_18-12-54_mercury-X99
    │   └── events.out.tfevents.1764929579.mercury-X99.2370976.0
    └── Dec06_09-19-10_mercury-X99
        └── events.out.tfevents.1764983955.mercury-X99.2014499.0

7 directories, 17 files


tree my_customer_service_lora
my_customer_service_lora
├── adapter_config.json
├── adapter_model.safetensors
├── README.md
├── special_tokens_map.json
├── tokenizer_config.json
└── tokenizer.json

1 directory, 6 files
```