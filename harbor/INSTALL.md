### INSTALL HARBOR

1. [harbor官网](https://goharbor.io/)
2. [harbor 下载](https://github.com/goharbor/harbor/releases)

### 准备工作
```bash
wget https://github.com/goharbor/harbor/releases/download/v2.14.0/harbor-offline-installer-v2.14.0.tgz

tar -zxvf harbor-offline-installer-v2.14.0.tgz

cd harbor
```

### 修改配置
```bash
cp harbor.yml.tmpl harbor.yml
vi harbor.yml

1. 将 hostname: reg.mydomain.com 修改为 hostname: 192.168.1.100 [安装机器IP地址]
2. 注释 https 相关配置
```

### 执行安装
```bash
sudo ./install.sh
```

[http://192.168.1.100](http://192.168.1.100)
```
默认账号为: admin
默认密码为: Harbor12345
```