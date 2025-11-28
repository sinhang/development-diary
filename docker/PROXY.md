### DOCKER PROXY

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d

sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
Environment="NO_PROXY=localhost,127.0.0.1,::1"
EOF

# 为 docker 加入 dns
vi sudo vi /etc/docker/daemon.json
# 加入：
{
    "dns": ["8.8.8.8", "114.114.114.114"]
}

sudo systemctl daemon-reload
sudo systemctl restart docker


# check
systemctl show docker | grep Environment
```