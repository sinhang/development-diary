### PROXY

```bash
sudo mkdir -p /etc/systemd/system/containerd.service.d
sudo tee /etc/systemd/system/containerd.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF
```

```bash
sudo systemctl daemon-reexec
sudo systemctl restart containerd
```

```bash
sudo ctr -n k8s.io images pull cr.fluentbit.io/fluent/fluent-bit:4.2.0-amd64
```