### ncdu

ncdu 是一个命令行工具，用于查看磁盘空间使用情况。

ncdu 的安装可以使用以下命令：
```bash
sudo apt install ncdu -y
# 显示当前目录的磁盘使用情况。
ncdu /

# 显示当前目录的磁盘使用情况，并忽略大小为 0 的文件。
ncdu -x0 /

# 显示当前目录的磁盘使用情况，并忽略大小为 0 的文件，并忽略大小为 0 的目录。
ncdu -x0 -s0 /

# 显示指定目录的磁盘使用情况。
ncdu /path/to/directory
```