### caddy

```bash
sudo apt install caddy

sudo pkill -f "caddy reverse-proxy"
ps -ef | grep caddy


```

```text
# /etc/caddy/Caddyfile
# 添加一下内容
https://192.168.1.90, https://openclaw-2.local {
    tls internal
    reverse_proxy localhost:18789
}
```

### command
```bash
#后台启动服务：
sudo caddy start --config /etc/caddy/Caddyfile

#查看状态：
sudo caddy status

#停止服务：
sudo caddy stop

#重启服务：
sudo caddy restart --config /etc/caddy/Caddyfile
```

### systemctl
```bash
# 重新加载 systemd 配置
sudo systemctl daemon-reload

# 启动 Caddy 服务
sudo systemctl start caddy

# 设置开机自启
sudo systemctl enable caddy

# 查看状态
sudo systemctl status caddy

# 查看日志
sudo journalctl -u caddy -f
```

# 局域网访问 opencalw
# https://192.168.1.90
# https://openclaw-2.local