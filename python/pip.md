### PIP

### pip 查询指定包的版本列表
```shell
# 3.10
pip index versions PACKAGE_NAME
# 3.12
pip install package==

# 添加镜像源
# --index-url https://repo.huaweicloud.com/repository/pypi/simple
```

### pip 导出包版本
```shell
pip freeze > requirements.txt
```

### 设置华为源
```bash
pip config set global.index-url https://repo.huaweicloud.com/repository/pypi/simple
pip config set global.trusted-host repo.huaweicloud.com
```

### pip 升级
```shell
pip install --upgrade PACKAGE_NAME
pip install --upgrade pip
```

### 查询包版本
```shell
pip list | grep -E "(torch|mmcv|mmpose|numpy)"
pip show PACKAGE_NAME
```