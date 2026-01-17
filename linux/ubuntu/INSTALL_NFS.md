### INSTALL NFS SERVER


### server
```bash
sudo apt install nfs-kernel-server -y
sudo mkdir -p /mnt/nfs/data
sudo chown nobody:nogroup /mnt/nfs/data
sudo chmod 777 /mnt/nfs/data
sudo nano /etc/exports
# /mnt/hdd/nfs/data *(rw,sync,no_root_squash)
#/mnt/hdd/nfs/data *(rw,sync,no_subtree_check,no_root_squash)
/mnt/hdd/nfs *(rw,sync,no_subtree_check,fsid=0,no_root_squash)
/mnt/hdd/nfs/data *(rw,sync,no_subtree_check,no_root_squash)

/mnt/hdd/nfs/comfyui/input *(ro,sync,no_subtree_check,no_root_squash)
/mnt/hdd/nfs/comfyui/output *(ro,sync,no_subtree_check,no_root_squash)

sudo exportfs -a
sudo systemctl restart nfs-kernel-server
sudo systemctl status nfs-kernel-server
```

### client
```bash
# 安装客户端
sudo apt update
sudo apt full-upgrade -y
sudo apt install nfs-common -y
# 挂载
sudo mount -t nfs4 192.168.1.27:/mnt/hdd/nfs/data /mnt/nfs

sudo mount -t nfs 192.168.1.27:/data /mnt/nfs
```


### 注意v3/v4版本差异 - 指定版本
```bash
sudo mount -t nfs -o vers=3 192.168.1.27:/mnt/hdd/nfs/data /tmp/testnfs

# v4 版本
sudo mount -t nfs 192.168.1.27:/data /tmp/testnfs


sudo mount -t nfs 192.168.1.100:/comfyui/input /mnt/hdd2/workflow/input
```

### 客户端添加到开机启动
```bash
sudo vi /etc/fstab
192.168.1.100:/comfyui/input  /mnt/hdd2/workflow/input  nfs  _netdev,noatime  0  0
192.168.1.100:/comfyui/output /mnt/hdd2/workflow/output nfs  _netdev,noatime  0  0
# or
192.168.1.100:/comfyui/input  /mnt/hdd2/workflow/input  nfs  _netdev,x-systemd.automount  0  0
192.168.1.100:/comfyui/output  /mnt/hdd2/workflow/output  nfs  _netdev,x-systemd.automount  0  0
# or
192.168.1.100:/comfyui/input  /mnt/hdd2/workflow/input  nfs  _netdev,x-systemd.automount,noatime,actimeo=0  0  0
192.168.1.100:/comfyui/output /mnt/hdd2/workflow/output nfs  _netdev,x-systemd.automount,noatime,actimeo=0  0  0


192.168.1.100:/comfyui/input  /mnt/nfs/input  nfs  _netdev,x-systemd.automount,noatime,actimeo=0  0  0
192.168.1.100:/comfyui/output  /mnt/nfs/output  nfs  _netdev,x-systemd.automount,noatime,actimeo=0  0  0


# 重新加载 systemd 配置
sudo systemctl daemon-reload

# 显示挂载信息
sudo mount -a

```
| 参数                    | 作用                       |
| --------------------- | ------------------------ |
| `actimeo=0`           | 禁用 attribute & dir cache |
| `_netdev`             | 等网络                      |
| `x-systemd.automount` | 按需挂载                     |
| `noatime`             | 减 IO                     |