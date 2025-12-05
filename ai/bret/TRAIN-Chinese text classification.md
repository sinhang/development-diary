### TRAIN BRET bert-base-chinese 中文文本分类模型


### 安装依赖
```bash
# 如果有显卡，则使用gpu训练，安装对应版本的 cuda
nvidia-smi
pip install torch==2.9.1+cu130 torchvision==0.24.1+cu130 torchaudio==2.9.1+cu130 --index-url https://download.pytorch.org/whl/cu130
# 没有显卡，则使用cpu训练
pip install torch torchvision torchaudio
# 其他依赖
pip install datasets transformers
```

### 模型训练 bert_trainer.py
```python
import pickle
import json
import time
from typing import List, Dict, Tuple
from pathlib import Path
import torch
import numpy as np
from transformers import BertTokenizer, BertForSequenceClassification
from transformers.trainer import Trainer
from transformers.training_args import TrainingArguments
from datasets import Dataset
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import warnings

class BertTrainer:

    def __init__(self, model_name: str, max_length: int = 128, device_type: str = "auto"):
        """
        初始化训练器

        Args:
            model_name: 模型名称
            max_length: 最大序列长度
            device_type: 设备类型
        """
        self.model_name = model_name
        self.max_length = max_length

        if device_type == "auto":
            self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        else:
            self.device = torch.device(device_type)


        # 初始化组件
        self.tokenizer = None
        self.model = None
        self.label_encoder = None
        self.trainer = None

        # 初始化数据存储
        self.train_texts = []
        self.train_labels = []
        self.val_texts = []
        self.val_labels = []

        # 训练历史
        self.training_history = {}


    def prepare_data(self, texts: List[str], labels: List[str], test_size: float = 0.2, random_state: int = 42, stratify: bool = True) -> Dict:
        """
        准备训练数据

        Args:
            texts: 文本列表
            labels: 标签列表
            test_size: 测试集比例
            random_state: 随机种子
            stratify: 是否进行分层采样

        Returns:
            Dict: 训练数据
        """

        # 检查数据长度
        if len(texts) != len(labels):
            raise ValueError("The length of texts and labels must be equal.")

        # 创建标签编码器
        self.label_encoder = LabelEncoder()
        encoded_labels = self.label_encoder.fit_transform(labels)

        # 数据统计
        unique_labels, counts = np.unique(encoded_labels, return_counts=True)

        # 数据划分
        stratify_param = encoded_labels if stratify else None

        self.train_texts, self.val_texts, train_encoded, val_encoded = train_test_split(texts, encoded_labels, test_size=test_size, random_state=random_state, stratify=stratify_param)

        # 转换文本标签用于显示
        self.train_labels = self.label_encoder.inverse_transform(train_encoded).tolist()
        self.val_labels = self.label_encoder.inverse_transform(val_encoded).tolist()

        # 保存标签映射
        label_mapping = {}
        for i, label in unique_labels:
            idx = self.label_encoder.transform([label])[0]
            label_mapping[idx] = label

        return {
            "total_samples": len(texts),
            "num_classes": len(unique_labels),
            "train_size": len(self.train_texts),
            "val_size": len(self.val_texts),
            "label_mapping": label_mapping,
            "class_distribution": dict(zip(unique_labels, counts))
        }

    def initialize_model(self, num_labels: int) -> bool:
        """
        初始化模型和tokenizer

        Args:
            num_labels: 类别数量

        Returns:
            bool: 初始化是否成功
        """

        try:
            self.tokenizer = BertTokenizer.from_pretrained(self.model_name)

            # 确定类别数
            if num_labels is None:
                if self.label_encoder is None:
                    raise ValueError("Please provide the number of labels or call prepare_data() first.")
                
                num_labels = len(self.label_encoder.classes_)

            self.model = BertForSequenceClassification.from_pretrained(self.model_name, num_labels=num_labels).to(self.device)

            return True
        except Exception as e:
            print(f"Error initializing model: {e}")
            return False

    def create_dataset(self) -> Tuple[Dataset, Dataset]:
        """
        创建数据集
        """

        if not self.train_texts or not self.tokenizer:
            raise ValueError("Please call prepare_data() first.")

        # 编码训练数据
        train_encoded_labels = self.label_encoder.transform(self.train_labels)
        train_encodings = self.tokenizer(self.train_texts, truncation=True, padding=True, max_length=self.max_length)

        # 编码数据验证
        val_encoded_labels = self.label_encoder.transform(self.val_labels)
        val_encodings = self.tokenizer(self.val_texts, truncation=True, padding=True, max_length=self.max_length)

        # 创建数据集
        train_dataset = Dataset.from_dict({
            "input_ids": train_encodings["input_ids"],
            "attention_mask": train_encodings["attention_mask"],
            "labels": train_encoded_labels.tolist()
        })

        val_dataset = Dataset.from_dict({
            "input_ids": val_encodings["input_ids"],
            "attention_mask": val_encodings["attention_mask"],
            "labels": val_encoded_labels.tolist()
        })

        return train_dataset, val_dataset

    def train(self, 
            output_dir: str, 
            num_train_epochs: int = 3,
            per_device_train_batch_size: int = 8,
            per_device_eval_batch_size: int = 8,
            warmup_steps: int = 100,
            weight_decay: float = 0.01,
            learning_rate: float = 2e-5,
            logging_steps: int = 10,
            evel_strategy: str = "epoch",
            load_best_model_at_end: bool = True,
            **kwargs) -> Dict:
            """
            训练模型

            Args:
                output_dir: 模型保存路径
                num_train_epochs: 训练轮数
                per_device_train_batch_size: 每个设备训练批次大小
                per_device_eval_batch_size: 每个设备验证批次大小
                warmup_steps: 预热步数
                weight_decay: 权重衰减
                learning_rate: 学习率
                logging_steps: 日志步数
                evel_strategy: 评估策略
                load_best_model_at_end: 是否加载最佳模型
                **kwargs: 其他参数

            Returns:
                Dict: 训练结果
            """

            if not self.model or not self.tokenizer:
                raise ValueError("Please call initialize_model() first.")

            # 创建数据集
            train_dataset, val_dataset = self.create_dataset()

            # 训练参数
            training_args = TrainingArguments(
                output_dir=output_dir,
                num_train_epochs=num_train_epochs,
                per_device_train_batch_size=per_device_train_batch_size,
                per_device_eval_batch_size=per_device_eval_batch_size,
                warmup_steps=warmup_steps,
                weight_decay=weight_decay,
                learning_rate=learning_rate,
                logging_dir=f"{output_dir}/logs",
                logging_steps=logging_steps,
                save_strategy=evel_strategy,
                eval_strategy=evel_strategy,
                load_best_model_at_end=load_best_model_at_end,
                metric_for_best_model="accuracy",
                greater_is_better=True,
                **kwargs
            )

            # 评估函数
            def compute_metrics(eval_pred):
                predictions, labels = eval_pred
                predictions = np.argmax(predictions, axis=1)
                accuracy = accuracy_score(labels, predictions)
                return {"accuracy": accuracy}

            # 创建训练器
            trainer = Trainer(
                model=self.model,
                args=training_args,
                train_dataset=train_dataset,
                eval_dataset=val_dataset,
                compute_metrics=compute_metrics
            )

            # 记录训练开始时间
            start_time = time.time()

            # 开始训练
            train_result = trainer.train()

            # 获取训练时间
            train_time = time.time() - start_time

            # 评估模型
            eval_result = trainer.evaluate()

            # 保存训练历史
            self.training_history = {
                "train_result": train_result,
                "eval_result": eval_result,
                "train_time": train_time
                "training_args": training_args,
                "data_info": {
                    "train_size": len(train_dataset),
                    "val_size": len(val_dataset),
                    "num_classes": len(self.label_encoder.classes_)
                    "classes": self.label_encoder.classes_
                }
            }

            return self.training_history

    def save_model(self, save_dir: str, include_training_info: bool = True) -> str:
        """
        保存模型
        
        Args:
            save_dir: 保存路径
            include_training_info: 是否保存训练信息

        Returns:
            str: 保存路径
        """

        if not self.model or not self.tokenizer or not self.label_encoder:
            raise ValueError("Please call initialize_model() first.")

        save_path = Path(save_dir)
        save_path.mkdir(parents=True, exist_ok=True)

        # 保存模型和tokenizer
        self.model.save_pretrained(save_path)
        self.tokenizer.save_pretrained(save_path)

        # 保存标签编码器
        with open(save_path / "label_encoder.pkl", "wb") as f:
            pickle.dump(self.label_encoder, f)

        if include_training_info: and self.training_history:
            with open(save_path / "training_history.json", "w", encoding="utf-8") as f:
                history_copy = json.dumps(self.training_history, default=str)
                json.dump(history_copy, f, ensure_ascii=False, indent=2)

        # 保存模型信息
        model_info = {
            "model_name": self.model_name,
            "max_length": self.max_length,
            "num_classes": len(self.label_encoder.classes_),
            "classes": self.label_encoder.classes_.tolist(),
            "device_type": str(self.device_type),
            "save_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        with open(save_path / "model_info.json", "w", encoding="utf-8") as f:
            json.dump(model_info, f, ensure_ascii=False, indent=2)

        return str(save_path)

    def quick_train(self, texts: List[str] = None, labels: List[str] = None, save_dir: str, **train_kwargs) -> Dict:
        """
        快速训练模型

        Args:
            texts: 训练文本列表
            labels: 训练标签列表
            save_dir: 保存目录
            **train_kwargs: 训练参数
        Returns:
            Dict: 训练结果
        """

        data_info = self.preprocess_data(texts, labels)

        if not self.initialize_model():
            raise ValueError("initialize model failed")

        # 训练模型
        train_result = self.train_model(output_dir=f"{save_dir}_training", **train_kwargs)

        # 保存模型
        saved_path = self.save_model(save_dir)

        # 汇总结果
        return {
            "data_info": data_info,
            "training_result": train_result,
            "saved_path": saved_path
            "model_info": {
                "model_name": self.model_name,
                "max_length": self.max_length,
                "device_type": str(self.device_type),
            }
        }

def quick_train_bert(texts: List[str] = None, labels: List[str] = None, 
                        model_name: str = "hfl/chinese-macbert-base", save_dir: str = "./train_result", 
                        epochs: int = 3) -> Dict:

    """
    快速训练BERT模型
    
    Args:
        texts: 训练文本列表
        labels: 训练标签列表
        model_name: 模型名称
        save_dir: 保存目录
        epochs: 训练轮数

    Returns:
        Dict: 训练结果
    """

    trainer = BertTrainer(model_name=model_name)

    return trainer.quick_train(texts=texts, labels=labels, save_dir=save_dir, epochs=epochs)

if __name__ == "__main__":
    texts = [
            # 技术类
            "如何修复电脑蓝屏", "Windows系统崩溃解决方案", "网络连接问题排查", "硬盘坏道修复教程",
            "路由器设置指南", "电脑运行缓慢优化", "病毒查杀方法", "系统重装步骤",
            "内存不足处理方案", "显卡驱动更新", "电脑死机怎么办", "USB设备无法识别",
            
            # 科技新闻
            "新款手机发布会", "苹果发布新iPhone", "华为新机上市", "小米发布会直播",
            "特斯拉新车型曝光", "AI技术最新突破", "5G网络建设进展", "芯片行业动态",
            "互联网公司财报", "科技巨头并购案", "新能源汽车销量", "智能家居趋势",
            
            # 编程类
            "Python编程教程", "Java基础入门教程", "JavaScript前端开发", "机器学习算法",
            "数据结构与算法", "Web开发实战", "移动App开发", "数据库设计原理",
            "云计算技术栈", "DevOps实践指南", "Python机器学习教程", "React框架学习",
            
            # 金融类
            "2023年股市分析", "年收入高达50W", "投资理财建议", "基金定投策略",
            "房价走势预测", "保险产品对比", "贷款利率变化", "外汇交易技巧",
            "期货投资入门", "债券市场分析", "理财产品推荐", "财务规划方案"
        ]
    
    labels = [
        # 技术类
        "技术", "技术", "技术", "技术", "技术", "技术", "技术", "技术", 
        "技术", "技术", "技术", "技术",
        # 科技新闻类  
        "科技新闻", "科技新闻", "科技新闻", "科技新闻", "科技新闻", "科技新闻", 
        "科技新闻", "科技新闻", "科技新闻", "科技新闻", "科技新闻", "科技新闻",
        # 编程类
        "编程", "编程", "编程", "编程", "编程", "编程", "编程", "编程", 
        "编程", "编程", "编程", "编程",
        # 金融类
        "金融", "金融", "金融", "金融", "金融", "金融", "金融", "金融", 
        "金融", "金融", "金融", "金融"
    ]

    result = quick_train_bert(texts=texts, labels=labels, epochs=5)

    print("🎉 训练完成!")
    print(f"📊 准确率: {result['training_result']['eval_result']['eval_accuracy']:.4f}")
    print(f"💾 模型保存路径: {result['saved_path']}")
```

### 文本预测 bert_text_classifier.py
```python
import torch
import pickle
import os
import json
import time
from typing import List, Dict, Optional, Union
from transformers import BertTokenizer, BertForSequenceClassification
from sklearn.preprocessing import LabelEncoder
import warnings

class BertTextClassifier: 

    def __init__(self, model_path: str = "./train_result", device_type: str = "auto", max_length: int = 128):
        """
        初始化文本分类器

        Args:
            model_path: 模型路径
            device_type: 设备类型
        """

        self.model_path = model_path
        self.max_length = max_length
        self.model = None
        self.tokenizer = None
        self.label_encoder = None

        # 设备选择
        if device_type == "auto":
            self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        else:
            self.device = torch.device(device_type)

        self.is_loaded = False

    def load_model(self) -> bool:
        """
        加载模型

        Returns:
            bool: 是否加载成功
        """

        try:

            # 加载 tokenizer
            self.tokenizer = BertTokenizer.from_pretrained(self.model_path)

            # 加载模型
            self.model = BertForSequenceClassification.from_pretrained(self.model_path)
            self.model.to(self.device)
            self.model.eval()

            if not self._load_label_encoder():
                raise ValueError('标签编码器文件不存在！')
        
            self.is_loaded = True
            return True
        except Exception as e:
            raise e

    def _load_label_encoder(self) -> bool:
        """
        加载标签编码器
        """

        label_encoder_path = os.path.join(self.model_path, "label_encoder.max_seq_lenpkl")

        if os.path.exists(label_encoder_path):
            with open(label_encoder_path, "rb") as f:
                self.label_encoder = pickle.load(f)
            return True
        
        raise False

    def predict(self, text: str) -> Dict[str, Union[str, float, Dict[str, float]]]:
        """
        预测单个文本

        Args:
            text: 待预测文本

        Returns:
            Dict[str, Union[str, float, Dict[str, float]]]: 预测结果
        """

        if not self.is_trained and not self.load_model():
            raise RuntimeError("模型加载失败")

        try:
            inputs = self.tokenizer(
                text,
                return_tensors="pt",
                truncation=True,
                padding=True,
                max_length=self.max_length
            ).to(self.device)

            # 预测
            with torch.no_grad():
                outputs = self.model(**inputs)
                probabilities = torch.softmax(outputs.logits, dim=-1)
                predicted_index = torch.argmax(probabilities, dim=-1).item()
                confidence = probabilities.max().item()

            # 获取预测标签
            predicted_label = self.label_encoder.inverse_transform([predicted_index])[0]

            # 获取所有类别概率分布
            all_probabilities = probabilities.squeeze().cpu().numpy()

            prob_dict = {}
            for i, label in enumerate(self.label_encoder.classes_):
                prob_dict[label] = all_probabilities[i]

            return {
                "text": text,
                "label": predicted_label,
                "confidence": confidence,
                "probabilities": prob_dict,
                "time": time.time()
            }
        except Exception as e:
            raise e

    def predict_batch(self, texts: List[str], show_progress: bool = True) -> List[Dict]:
        """
        批量预测

        Args:
            texts (List[str]): 待预测的文本列表
            show_progress (bool): 是否显示进度

        Returns:
            List[Dict]: 预测结果列表
        """

        if not self.is_trained and not self.load_model():
            raise RuntimeError("模型加载失败")

        results = []
        total = len(texts)

        if total == 0:
            raise ValueError("texts is empty")

        for i, text in enumerate(texts, 1):
            try:
                results.append(self.predict(text))
                if show_progress:
                    print("\r进度: {:.2f}%".format(i / total * 100), end="")
            except Exception as e:
                print("预测第 {} 条数据时出错: {}".format(i, e))
                results.append({
                    "text": text, 
                    "label": "未知", 
                    "confidence": 0.0,
                    "probabilities": {},
                    "error": str(e),
                    "timestamp": time.time(),
                })
                # raise RuntimeError("预测第 {} 条数据时出错: {}".format(i, e))

        return results

    def save_predictions(self, texts, output_file: str = "predictions.json") -> List[Dict]:
        """
        保存预测结果

        Args:
            texts (List[str]): 待预测的文本列表
            output_file (str): 保存预测结果的文件名

        Returns:
            List[Dict]: 预测结果列表
        """

        results = self.predict_batch(texts)

        # 保存预测结果
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(results, f, ensure_ascii=False, indent=4)

        success_count = sum(1 for r  in results if 'error' not in r)
        print(f"预测成功数：{success_count}，总预测数：{len(results)}")
        print(f"预测成功率：{success_count / len(results):.2%}")

        return results

    def get_model_info(self) -> Dict:
        """
        获取模型信息
        """

        if not self.is_loaded:
            raise ValueError("请先调用load_model方法加载模型")

        return {
            "status": "success",
            "model_path": self.model_path,
            "device": str(self.device),
            "label_num": len(self.label_encoder.classes_),
            "label_list": list(self.label_encoder.classes_),
        }


    def evaluate_confidence_distribution(self, texts: List[str]) -> Dict:
        """
        评估模型预测的置信度分布

        Args:
            texts (List[str]): 待预测的文本列表

        Returns:
            Dict: 模型预测的置信度分布
        """

        results = self.predict_batch(texts, show_progress=False)

        confidences = [r["confidence"] for r in results if "error" not in r]

        if not confidences:
            raise ValueError("No valid predictions were made.")


        # 按类别统计
        category_stats = {}
        for result in results:
            if "error" in result:
                continue
            label = result["predicted_label"]
            if label not in category_stats:
                category_stats[label] = []

            category_stats[label].append(result["confidence"])

        # 计算统计信息
        import numpy as np

        analytics = {
            "总样本数": len(results),
            "有效预测数": len(confidences),
            "平均置信度": np.mean(confidences),
            "置信度中位数": np.median(confidences),
            "最高置信度": np.max(confidences),
            "最低置信度": np.min(confidences),
            "高置信度样本数 (>0.8)": len([1 for c in confidences if c > 0.8]),
            "低置信度样本数 (<0.5)": len([1 for c in confidences if c < 0.5]),
            "各类别统计": {}
        }

        for label, confs in category_stats.items():
            analytics["各类别统计"][label] = {
                "样本数": len(confs),
                "平均置信度": np.mean(confs),
                "最高置信度": np.max(confs),
                "最低置信度": np.min(confs)
            }

        return analytics

def quick_predict(text: str, model_path: str = "./train_result") -> Dict:
    """
    快速预测

    Args:
        text (str): 待预测文本
        model_path (str, optional): 模型路径. Defaults to "./train_result".

    Returns:
        Dict: 预测结果
    """

    classifier = Classifier(model_path)
    return classifier.predict(text)

def quick_predict_batch(texts: List[str], model_path: str = "./train_result") -> List[Dict]:
    """
    批量快速预测

    Args:
        texts (List[str]): 待预测文本列表
        model_path (str, optional): 模型路径. Defaults to "./train_result".

    Returns:
        List[Dict] 预测结果列表
    """

    classifier = Classifier(model_path)

    return classifier.predict_batch(texts)

if __name == "__main__":
    quick_predict("中国是伟大的")
```