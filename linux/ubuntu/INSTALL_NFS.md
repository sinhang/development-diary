### INSTALL NFS SERVER

```bash
sudo apt install nfs-kernel-server -y
sudo mkdir -p /mnt/nfs/data
sudo chown nobody:nogroup /mnt/nfs/data
sudo chmod 777 /mnt/nfs/data
sudo nano /etc/exports
# /mnt/hdd/nfs/data *(rw,sync,no_root_squash)
/mnt/hdd/nfs/data *(rw,sync,no_subtree_check,no_root_squash)
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
```