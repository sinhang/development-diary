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