### 安装 ssh server

```shell
sudo apt install openssh-server -y

# 启动服务
sudo systemctl start ssh

# 设置开机自启
sudo systemctl enable ssh

# 检查服务状态
sudo systemctl status ssh

# 允许 SSH 连接（默认端口 22）
sudo ufw allow ssh

# 或者明确指定端口
sudo ufw allow 22/tcp

# 启用防火墙（如果尚未启用）
sudo ufw enable


# 检查 SSH 服务状态
sudo systemctl status ssh

# 检查 SSH 是否在监听
sudo ss -tlnp | grep :22

# 或者使用 netstat
sudo netstat -tlnp | grep :22
```

### 配置信息
```shell
# 备份原配置
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 编辑配置
sudo nano /etc/ssh/sshd_config

# 修改默认端口（可选）
Port 2222

# 禁止 root 登录（增强安全）
PermitRootLogin no

# 允许密码认证
PasswordAuthentication yes

# 最大认证尝试次数
MaxAuthTries 3
```

### 连接 ssh
```shell
ssh root@192.168.1.100
```