### supervisor 站点资源
1. [supervisor github](https://github.com/Supervisor/supervisor)
2. [supervisor 官网](https://supervisord.org/)

### 安装
```shell
sudo apt install -y supervisor
# or
pip install supervisor
```

### 查看版本
```shell
sudo supervisord --version
```

### 配置文件
```shell
# supervisord 配置文件
sudo vi /etc/supervisor/supervisord.conf

# supervisorctl 配置文件
ls /etc/supervisor/conf.d/
```

### 新建任务
```shell
echo "[program:program_name]
command=program_command
autostart=true
autorestart=true
stdout_logfile=/var/log/program_command/run.log
stderr_logfile=/var/log/program_command/err.log" | sudo tee /etc/supervisor/conf.d/program_command.conf > /dev/null
```

### supervisorctl command
```shell
sudo supervisorctl update

# 查看任务状态
sudo supervisorctl status

# 启动任务
sudo supervisorctl start program_name

# 停止任务
sudo supervisorctl stop program_name

# 重启任务
sudo supervisorctl restart program_name

# 启动所有任务
sudo supervisorctl start all

# 停止所有任务
sudo supervisorctl stop all
```