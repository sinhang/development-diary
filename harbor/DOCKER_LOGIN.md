### Docker Login

1. 设置镜像仓库
```bash
# 打开/创建文件
sudo vi /etc/docker/daemon.json
# 写入
{
  "insecure-registries": ["192.168.1.27:8090"]
}
```
2. 重启 docker
```bash
sudo systemctl restart docker
```
3. 登录镜像仓库
```bash
sudo docker login -u admin -p Harbor12345 192.168.1.27:8090
# 或者
sudo docker login 192.168.1.27:8090
Username: admin
Password: <PASSWORD>
```

### 登录成功
```
Login Succeeded
```