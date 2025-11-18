### 查看磁盘
```shell
sudo fdisk -l
# 或者
sudo lsblk
```

### 创建挂载点
```shell
sudo mkdir /mnt/hdd
```

### 获取磁盘信息
```shell
sudo blkid
# 输出
# /dev/sdb: LABEL="work" UUID="b863e2d2-d7c1-460e-87db-033df4e0db5b" BLOCK_SIZE="4096" TYPE="ext4"

# 只显示指定盘
sudo blkid /dev/sdb
# /dev/sdb: LABEL="work" UUID="b863e2d2-d7c1-460e-87db-033df4e0db5b" BLOCK_SIZE="4096" TYPE="ext4"
```

### 备份 /etc/fstab
```shell
sudo cp /etc/fstab /etc/fstab.backup
```

### 编辑 /etc/fstab
```shell
sudo nano /etc/fstab

# 在文件末尾添加挂载信息
# 格式：UUID=你的UUID   挂载点   文件系统类型   挂载选项    dump fsck
UUID=b863e2d2-d7c1-460e-87db-033df4e0db5b /mnt/hdd ext4 defaults 0 2
```

### 检查挂载状态
```shell
# 重新加载 systemd 配置
sudo systemctl daemon-reload

# 显示挂载信息
sudo mount -a
# 如果没有任何输出则证明挂载成功

# 列出挂载目录文件
ls /mnt/hdd
```