### pyenv github 仓库
1. [pyenv](https://github.com/pyenv/pyenv)

### 安装 pyenv

```shell
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

### 安装指定版本的 Python

```shell
pyenv install 3.12.7
```

### 指定全局Python版本

```shell
pyenv global 3.12.7
```

### 在项目目录下面指定Python版本

```shell
pyenv local 3.12.7
```

### pyenv command
```shell
# 移除指定Python版本
pyenv uninstall 3.12.7

# 列出所有已Python版本
pyenv versions

# 列出所有可以安装的版本
pyenv install --list
```