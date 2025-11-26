### add group

```bash
sudo groupadd <group_name>
```
### add user to group
```bash
sudo usermod -aG <group_name> <username>
```
### 从一个组中移除用户
```bash
sudo gpasswd -d <username> <group_name>
```

### change group of file
```bash
sudo chgrp <group_name> <file_name>
```

## change owner of file
```bash
sudo chown <username> <file_name>
```

## change permission of file
```bash
sudo chmod <permission> <file_name>
```

## change permission of directory
```bash
sudo chmod -R <permission> <directory_name>
```

### delete group
```bash
sudo groupdel <group_name>
```

### add user
```bash
sudo useradd <username>
```
### change password
```bash
sudo passwd <username>
```
### delete user
```bash
sudo userdel <username>
```